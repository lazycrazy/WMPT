using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using WMPT.Infrastructure.Logging;
using WMPT.Models;
using System.Data;

namespace WMPT.Infrastructure
{
    public class WMHelper
    {
        public static NLog.Logger Logger = NLog.LogManager.GetCurrentClassLogger();


        public static volatile Dictionary<string, string> AccessTokens = new Dictionary<string, string>();


        public static async Task<JObject> PostJson(string url, object data)
        {
            string postDataStr = "";
            try
            {
                var request = (HttpWebRequest)WebRequest.Create(url);
                request.Method = "POST";
                request.ContentType = "application/json";
                postDataStr = JsonConvert.SerializeObject(data);
                var jsonData = Encoding.UTF8.GetBytes(postDataStr);
                request.ContentLength = jsonData.Length;
                using (var reqStream = await request.GetRequestStreamAsync())
                {
                    await reqStream.WriteAsync(jsonData, 0, jsonData.Length);
                }
                string retString = "";
                using (var response = await request.GetResponseAsync())
                {
                    using (var myResponseStream = response.GetResponseStream())
                    {
                        using (var myStreamReader = new StreamReader(myResponseStream, Encoding.GetEncoding("utf-8")))
                        {
                            retString = await myStreamReader.ReadToEndAsync();
                        }
                    }
                }
                try
                {
                    //retString = retString.TrimStart('"').TrimEnd('"');
                    var rs = JObject.Parse(retString);
                    return rs;
                }
                catch (Exception ex)
                {
                    Logger.Error(ex, "请求URL失败：" + url + " 数据：" + postDataStr);
                    Logger.Error("解析返回JSON失败：" + retString);
                    Logger.Error(ex);
                    return null;
                }

            }
            catch (Exception ex)
            {
                Logger.Error(ex, "请求URL失败：" + url + " 数据：" + postDataStr);
                Logger.Error(ex);
                return null;
            }

        }

        public static async Task<JObject> RequestUrl(string url, string method)
        {
            var request = (HttpWebRequest)WebRequest.Create(url);
            request.Method = method;
            string retString;
            using (var response = await request.GetResponseAsync())
            {
                using (var myResponseStream = response.GetResponseStream())
                {
                    using (var myStreamReader = new StreamReader(myResponseStream, Encoding.GetEncoding("utf-8")))
                    {
                        retString = myStreamReader.ReadToEnd();
                    }
                }
            }
            var rsJson = JObject.Parse(retString);
            return rsJson;
        }
        public static async Task<bool> RefreshToken(string pid)
        {
            var rs = Massive.DB.Current.Query(@"SELECT WMGZH.*, WMAPPS.CLIENT_SECRET
  FROM WMGZH JOIN WMAPPS ON WMAPPS.client_id = WMGZH.client_id
 WHERE pid = :0", pid).First();
            string url = string.Format(Urls.RefreshAccessToken, rs.CLIENT_ID, rs.CLIENT_SECRET, rs.REFRESH_TOKEN);

            dynamic rsJson;

            try
            {
                rsJson = await RequestUrl(url, "POST");

                AccessTokens[pid] = rsJson.access_token.Value;
                //记录成功日志
                var msg = new { type = "刷新token", url = url, status = "成功", accesstoken = AccessTokens[pid] };
                Logger.Error(JsonConvert.SerializeObject(msg));
            }
            catch (Exception ex)
            {
                var msg = new { type = "刷新token", url = url, status = "失败" };
                Logger.Error(ex, JsonConvert.SerializeObject(msg));
                Logger.Error(ex);
                //记录错误日志
                throw ex;
            }

            var gzh = new Gzhs();
            gzh.Save(new { PID = pid, ACCESS_TOKEN = rsJson.access_token.Value });
            return true;

        }

        public static async Task<string> GetAccessToken(string pid)
        {
            if (AccessTokens.ContainsKey(pid) && AccessTokens[pid] != null) return AccessTokens[pid];

            await RefreshToken(pid);
            return AccessTokens[pid];
        }

        public static async Task UploadMember(string pid)
        {

            try
            {
                //添加同步号
                var syncs = new Syncs();
                int syncId = syncs.New(pid, "0");

                //调用存储过程，生成需要同步实体会员（新增，或者修改的实体会员，和已关联微盟会员的会员积分变更流水）， 传递参数 同步号syncId

                var db = Massive.DB.Current;
                using (var conn = db.OpenConnection())
                {
                    using (var cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = "PRC_ToWmmember_middleTab";
                        cmd.CommandType = CommandType.StoredProcedure;
                        var param = cmd.CreateParameter();
                        param.ParameterName = "V_PID";
                        param.Value = pid;
                        param.DbType = DbType.String;
                        var oparam = cmd.CreateParameter();
                        oparam.ParameterName = "OUTSTATUS";
                        oparam.Direction = ParameterDirection.Output;
                        oparam.DbType = DbType.Int32;
                        cmd.Parameters.Add(param);
                        cmd.Parameters.Add(oparam);
                        cmd.ExecuteNonQuery();
                        if (int.Parse(cmd.Parameters["OUTSTATUS"].Value.ToString()) != 0)
                        {
                            syncs.SetError(syncId);
                            Logger.Error("公众号：" + pid + "执行存储过程[PRC_ToWmmember_middleTab]失败,返回值：" + cmd.Parameters["OUTSTATUS"].Value);

                        }
                    }
                    conn.Close();
                }

                //添加或修改实体店会员到微盟
                await ModifyWmOfflineMember(syncId, pid, syncs);
                //修改已绑定微盟会员的积分
                await ModifyWmOfflinePoints(syncId, pid, syncs);

                syncs.SetSuccess(syncId);
            }
            finally
            {


            }

        }

        private static async Task ModifyWmOfflineMember(int syncId, string pid, dynamic syncs)
        {
            //获取需要新增实体会员 未同步，新增的会员，修改的会员
            var offlineMembers = new OfflineMembers();
            //遍历上传
            //上传新增实体会员


            foreach (dynamic o in offlineMembers.All(@where: "SYNCFLAG ='0' and PID=:0", args: pid))
            {
                var member = new
                {
                    name = o.NAME,
                    phone = o.PHONE,
                    sex = o.SEX == null ? 0 : (int)o.SEX,
                    birthday = o.BIRTHDAY == null ? "" : GetTimeStamp(DateTime.Parse(o.BIRTHDAY)).ToString(),//o.BIRTHDAY, 
                    address = new
                    {
                        provinceName = o.PROVINCENAME ?? "",
                        //provinceId = o.PROVINCEID ?? "",
                        cityName = o.CITYNAME ?? "",
                        //cityId = o.CITYID ?? "",
                        //districtName = o.DISTRICTNAME ?? "",
                        //districtId = o.DISTRICTID ?? "",
                        address = o.ADDRESS ?? "",
                        //mapType = o.MAPTYPE ?? 0,
                        //longitude = o.LONGITUDE ?? 0,
                        //latitude = o.LATITUDE ?? 0,
                        code = o.CODE ?? ""
                    },
                    growthValue = o.GROWTHVALUE == null ? 0 : (int)o.GROWTHVALUE,
                    points = o.POINTS == null ? 0 : (int)o.POINTS,
                    allPoints = o.ALLPOINTS == null ? 0 : (int)o.ALLPOINTS,
                    amount = o.AMOUNT ?? 0.00M,
                    allConsumingAmount = o.ALLCONSUMINGAMOUNT ?? 0.00M

                };
                var isNew = "1" == o.NEWFLAG;
                var url = String.Format(Urls.AddOfflineMemberInfo, await GetAccessToken(pid));
                if (!isNew)
                    url = String.Format(Urls.UpdateOfflineMemberInfo, await GetAccessToken(pid));
                //新增实体会员 
                dynamic rs = await WMHelper.PostJson(url, member);
                if (rs == null)
                {
                    syncs.SetError(syncId);
                    continue;
                }
                //记录日志
                //成功，回写标记
                if ("0" != rs.code.errcode.Value.ToString())
                {
                    //记录错误日志
                    var msg = new { pid, syncid = syncId, type = isNew ? "上传实体会员信息" : "修改实体会员信息", url = url, status = "失败", data = member, errmsg = rs.code.errmsg.Value.ToString() };
                    Logger.Error(JsonConvert.SerializeObject(msg));
                    if ("85001000000107" == rs.code.errcode.Value.ToString())
                    {
                        var updateFlag = new { SYNCID = syncId, SYNCFLAG = "1", SYNCTIME = "sysdate", NEWFLAG = "0" };
                        //会写状态
                        offlineMembers.Update(updateFlag, "pid=:0 and MEMBERCARDNO=:1", pid, o.MEMBERCARDNO);
                        syncs.AddEffectCount(syncId, 1);
                    }
                    else if ("8000103" == rs.code.errcode.Value.ToString())//超出调用限制
                    {
                        syncs.SetError(syncId);
                        break;
                    }
                    else
                        syncs.SetError(syncId);

                }
                else
                {
                    var msg = new { syncid = syncId, type = isNew ? "上传实体会员信息" : "修改实体会员信息", url = url, status = "成功", data = member };
                    Logger.Info(JsonConvert.SerializeObject(msg));
                    var updateFlag = new { SYNCID = syncId, SYNCFLAG = "1", SYNCTIME = "sysdate", NEWFLAG = "0" };
                    //会写状态
                    offlineMembers.Update(updateFlag, "pid=:0 and MEMBERCARDNO=:1", pid, o.MEMBERCARDNO);

                    syncs.AddEffectCount(syncId, 1);
                }
            }

        }

        /// <summary>
        /// 修改微盟会员积分
        /// </summary>
        /// <param name="syncId"></param>
        /// <param name="access_token"></param>
        /// <returns></returns>
        private static async Task ModifyWmOfflinePoints(int syncId, string pid, dynamic syncs)
        {
            //获取需要修改积分的实体店会员（已绑定微盟会员号）
            var offlinePointLogs = new OfflinePointLogs();


            //遍历修改积分
            foreach (dynamic o in offlinePointLogs.All(@where: "WMMEMBERCARDNO is not null and SYNCFLAG ='0' and pid=:0", args: pid))
            {
                //修改微盟会员积分 
                dynamic point = new
                {
                    memberCardNo = o.WMMEMBERCARDNO,
                    points = o.POINTS == null ? 0 : (int)o.POINTS,
                    //storeId = o.STOREID,
                    title = string.IsNullOrWhiteSpace(o.TITLE) ? "线下同步上传更新" : o.TITLE,
                    remark = string.IsNullOrWhiteSpace(o.REMARK) ? "线下同步上传更新" : o.REMARK,
                    isAboutGrowthValue = string.IsNullOrWhiteSpace(o.ISABOUTGROWTHVALUE) ? false : true,
                    @operator = string.IsNullOrWhiteSpace(o.OPERATOR) ? "WMUP" : o.OPERATOR,
                    pointsPayType = o.POINTSPAYTYPE ?? 0
                };
                var url = String.Format(Urls.ChangeMemberPoints, await GetAccessToken(pid));

                dynamic rs = await WMHelper.PostJson(url, point);
                if (rs == null)
                {
                    syncs.SetError(syncId);
                    continue;
                }

                //成功，回写标记
                if ("0" != rs.code.errcode.Value.ToString())
                {
                    //记录错误日志 
                    syncs.SetError(syncId);
                    var msg = new { pid, syncid = syncId, type = "修改会员积分", url = url, status = "失败", data = point, errmsg = rs.code.errmsg.Value.ToString() };
                    Logger.Error(JsonConvert.SerializeObject(msg));
                    if ("8000103" == rs.code.errcode.Value.ToString())//超出调用限制
                    {
                        break;
                    }
                }
                else
                {
                    var msg = new { syncid = syncId, type = "修改会员积分", url = url, status = "成功", data = point };
                    Logger.Info(JsonConvert.SerializeObject(msg));
                    var updateFlag = new { SYNCID = syncId, SYNCFLAG = "1", SYNCTIME = "sysdate" };
                    offlinePointLogs.Update(updateFlag, "ID = :0 and pid=:1", o.ID, pid);


                    syncs.AddEffectCount(syncId, 1);

                }

            }
        }
        public static long GetTimeStamp(DateTime dt)
        {
            System.DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1)); // 当地时区
            long timeStamp = (long)(dt - startTime).TotalSeconds; // 相差秒数
            return timeStamp;
        }

        public static DateTime GetDateTime(long timeStamp)
        {
            System.DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1)); // 当地时区
            DateTime dt = startTime.AddSeconds(timeStamp);
            return dt;
        }

        public static async Task DownloadMember(string pid)
        {

            try
            {
                string syncType = "1";
                var lastBeginTime = Syncs.GetLastBeginTime(syncType, pid);
                //添加同步号
                var syncs = new Syncs();
                int syncId = syncs.New(pid, syncType);



                //获取积分变更流水
                var queryParam = new
                {
                    begintime = WMHelper.GetTimeStamp(lastBeginTime),
                    pageIndex = 1,
                    pageSize = 100,
                    isOnlyEffective = false
                };
                //同步积分,新增wm会员积分流水记录
                await AddWmMemberPointLogs(syncId, pid, queryParam, syncs);


                //新增的微盟会员信息
                await AddWmMembers(syncId, pid, syncs);



                //调用存储过程，关联实体会员号与微盟会员号，同时修改对应实体店会员积分（添加现有系统表积分变更流水？那需要加上标记区分，别循环修改积分又上传线上微盟了）， 传递参数 同步号syncId


                var db = Massive.DB.Current;
                using (var conn = db.OpenConnection())
                {
                    using (var cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = "PRC_Wmmember_IMPORT";
                        cmd.CommandType = CommandType.StoredProcedure;
                        var param = cmd.CreateParameter();
                        param.ParameterName = "V_PID";
                        param.Value = pid;
                        param.DbType = DbType.String;
                        var oparam = cmd.CreateParameter();
                        oparam.ParameterName = "OUTSTATUS";
                        oparam.Direction = ParameterDirection.Output;
                        oparam.DbType = DbType.Int32;
                        cmd.Parameters.Add(param);
                        cmd.Parameters.Add(oparam);
                        cmd.ExecuteNonQuery();
                        if (int.Parse(cmd.Parameters["OUTSTATUS"].Value.ToString()) != 0)
                        {
                            syncs.SetError(syncId);
                            Logger.Error("公众号：" + pid + "执行存储过程[PRC_Wmmember_IMPORT]失败,返回值：" + cmd.Parameters["OUTSTATUS"].Value);
                        }
                    }
                    conn.Close();
                }
                //会写同步状态字段
                syncs.SetSuccess(syncId);
            }
            finally
            {
            }
        }

        private static async Task AddWmMembers(int syncId, string pid, dynamic syncs)
        {
            var wMMembers = new WMMembers();
            //修改
            var updateMembers = wMMembers.Query(@"
SELECT distinct MEMBERCARDNO
  FROM WMPOINTSLOG
 WHERE  exists ( select 1 from WMMEMBER where WMMEMBER.MEMBERCARDNO = WMPOINTSLOG.MEMBERCARDNO and WMMEMBER.PID =WMPOINTSLOG.PID  ) 
  and WMPOINTSLOG.syncid=:0   ", syncId).Select(m => (string)m.MEMBERCARDNO).ToList();

            var colNames =
              wMMembers.Query(@"SELECT column_name   FROM USER_TAB_COLUMNS WHERE TABLE_NAME = :0",
                              args: wMMembers.TableName).Select(c => c.COLUMN_NAME).ToList();
            foreach (string newMember in updateMembers)
            {
                var queryParam = new { memberCardNo = newMember };
                var url = string.Format(Urls.GetMemberInfo, await GetAccessToken(pid));
                dynamic rs = await WMHelper.PostJson(url, queryParam);
                if (rs == null)
                {
                    syncs.SetError(syncId);
                    continue;
                }
                if ("0" != rs.code.errcode.Value.ToString())
                {
                    syncs.SetError(syncId);
                    //log err
                    var msg = new { pid, syncid = syncId, type = "获取WM会员信息", url = url, status = "失败", data = queryParam, errmsg = rs.code.errmsg.Value.ToString() };
                    Logger.Error(JsonConvert.SerializeObject(msg));
                    if ("8000103" == rs.code.errcode.Value.ToString())//超出调用限制
                    {
                        break;
                    }
                    continue;
                }
                else
                {
                    var msg = new { syncid = syncId, type = "获取WM会员信息", url = url, status = "成功", data = queryParam };
                    Logger.Info(JsonConvert.SerializeObject(msg));
                }
                if (rs.data == null)
                {
                    var msg = new { syncid = syncId, type = "获取WM会员信息", url = url, status = "成功", data = queryParam, message = "返回结果没有data", result = rs.ToString() };
                    Logger.Error(JsonConvert.SerializeObject(msg));
                    continue;
                }
                var item = rs.data;
                if (item == null) continue;

                var e = GetNewObjByJObject(item, colNames);
                e.SYNCID = syncId;
                e.PID = pid;
                wMMembers.Update(e, "MEMBERCARDNO=:0 and PID=:1", newMember, pid);
                syncs.AddEffectCount(syncId, 1);
            }

            //新增
            var newMembers = wMMembers.Query(@"
SELECT distinct MEMBERCARDNO
  FROM WMPOINTSLOG
 WHERE  not exists ( select 1 from WMMEMBER where WMMEMBER.MEMBERCARDNO = WMPOINTSLOG.MEMBERCARDNO and WMMEMBER.PID =WMPOINTSLOG.PID  ) 
  and WMPOINTSLOG.PID=:0   ", pid).Select(m => (string)m.MEMBERCARDNO).ToList();

            foreach (string newMember in newMembers)
            {
                var queryParam = new { memberCardNo = newMember };
                var url = string.Format(Urls.GetMemberInfo, await GetAccessToken(pid));
                dynamic rs = await WMHelper.PostJson(url, queryParam);
                if (rs == null)
                {
                    syncs.SetError(syncId);
                    continue;
                }
                if ("0" != rs.code.errcode.Value.ToString())
                {
                    syncs.SetError(syncId);
                    //log err
                    var msg = new { pid, syncid = syncId, type = "获取WM会员信息", url = url, status = "失败", data = queryParam, errmsg = rs.code.errmsg.Value.ToString() };
                    Logger.Error(JsonConvert.SerializeObject(msg));
                    if ("8000103" == rs.code.errcode.Value.ToString())//超出调用限制
                    {
                        break;
                    }
                    continue;
                }
                else
                {
                    var msg = new { syncid = syncId, type = "获取WM会员信息", url = url, status = "成功", data = queryParam };
                    Logger.Info(JsonConvert.SerializeObject(msg));
                }
                if (rs.data == null)
                {
                    var msg = new { pid = pid, syncid = syncId, type = "获取WM会员信息", url = url, status = "成功", data = queryParam, message = "返回结果没有data", rs = rs.ToString() };
                    Logger.Error(JsonConvert.SerializeObject(msg));
                    //wMMembers.Execute("delete WMPOINTSLOG where MEMBERCARDNO=:0 and PID=:1 ", newMember, pid);
                    continue;
                }
                var item = rs.data;
                if (item == null) continue;
                var e = GetNewObjByJObject(item, colNames);
                e.SYNCID = syncId;
                e.PID = pid;
                wMMembers.Insert(e);
                syncs.AddEffectCount(syncId, 1);
            }

        }

        private static async Task<dynamic> GetPointLogs(int syncId, string pid, dynamic queryParam, dynamic syncs)
        {
            var url = string.Format(Urls.GetPointsLogPageListAndTotal, await GetAccessToken(pid));
            dynamic rs = await WMHelper.PostJson(url, queryParam);
            //var msg1 = new { pid, syncid = syncId, type = "获取WM积分流水", url = url, data = queryParam, rs = rs.ToString() };
            //Logger.Error(JsonConvert.SerializeObject(msg1));
            if (rs == null)
            {
                syncs.SetError(syncId);
                return null;
            }
            if ("0" != rs.code.errcode.Value.ToString())
            {
                syncs.SetError(syncId);

                var msg = new { pid, syncid = syncId, type = "获取WM积分流水", url = url, status = "失败", data = queryParam, errmsg = rs.code.errmsg.Value.ToString() };
                Logger.Error(JsonConvert.SerializeObject(msg));
                return null;
            }
            else
            {
                var msg = new { pid, syncid = syncId, type = "获取WM积分流水", url = url, status = "成功", data = queryParam };
                Logger.Info(JsonConvert.SerializeObject(msg));
            }
            if (rs.data == null || rs.data.totalCount == null)
            {
                var msg = new { syncid = syncId, type = "获取WM积分流水", url = url, status = "成功", data = queryParam, message = "返回结果没有data", result = rs.ToString() };
                Logger.Error(JsonConvert.SerializeObject(msg));
                return null;
            };
            int totalCount = (int)rs.data.totalCount.Value;
            if (totalCount == 0) return null;
            return rs;
        }

        public static async Task AddWmMemberPointLogs(int syncId, string pid, dynamic queryParam, dynamic syncs)
        {

            dynamic rs = await GetPointLogs(syncId, pid, queryParam, syncs);
            if (rs == null) return;

            int pageIdx = queryParam.pageIndex;
            int pageSize = queryParam.pageSize;
            int totalCount = (int)rs.data.totalCount.Value;

            ProcessPointLogs(syncId, pid, rs);

            int count = (int)Math.Ceiling(((decimal)totalCount / pageSize)) - pageIdx;

            for (int i = 0; i < count; i++)
            {
                var param = new { pageIndex = (pageIdx + 1 + i), queryParam.begintime, queryParam.pageSize, queryParam.isOnlyEffective };

                rs = await GetPointLogs(syncId, pid, param, syncs);
                if (rs == null) continue;

                ProcessPointLogs(syncId, pid, rs);
            }

        }

        private static void ProcessPointLogs(int syncId, string pid, dynamic rs)
        {
            var items = rs.data.items;
            var points = new List<dynamic>();
            var ids = new List<dynamic>();
            var wMPointLogs = new WMPointLogs();
            var colNames =
              wMPointLogs.Query(@"SELECT column_name   FROM USER_TAB_COLUMNS WHERE TABLE_NAME = :0",
                              args: wMPointLogs.TableName).Select(c => c.COLUMN_NAME).ToList();
            //Logger.Error("222222222222" + pid);
            foreach (var item in items)
            {
                if (item.@operator != null && item.@operator.Value != null && "WMUP" == item.@operator.Value.ToString()) continue;
                var e = GetNewObjByJObject(item, colNames);
                points.Add(e);
                ids.Add(item.id.Value);
                //"id": 311,
                //"memberCardNo": "111111100000136123",
                //"name": "Sara",
                //"title": "会员签到赠送积分",
                //"phone": "13323339201",
                //"storeId": 0,
                //"storeName": "",
                //"points": 0,
                //"time": 1488951604,
                //"pointsPayType": 7,
                //"addOrReduce": 0,
                //"operataor": "卡号：111111100000136123",
                //"remark": "会员签到赠送积分"
            }
            //Logger.Error("33333333333333" + pid);
            var existsIds = new List<long>();
            if (ids.Count > 0)
            {
                var strIds = string.Join(",", ids);
                existsIds = wMPointLogs.Query(string.Format("select id from WMPOINTSLOG where id in ({0}) and pid=:0", strIds), args: pid).Select(d => (long)d.ID).ToList();

            }
            //Logger.Error("444444444444444" + pid);

            var addPoints = points.Where(p => !existsIds.Exists(e => e == p.ID)).ToArray();
            if (addPoints.Length > 0)
            {
                foreach (dynamic addPoint in addPoints)
                {
                    addPoint.SYNCFLAG = "0";
                    addPoint.SYNCID = syncId;
                    addPoint.PID = pid;
                }
                wMPointLogs.SaveAsNew(addPoints);
            }
        }

        private static dynamic GetNewObjByJObject(dynamic item, List<dynamic> colNames)
        {
            dynamic e = new ExpandoObject();
            var newObj = (IDictionary<string, object>)e;
            foreach (var kv in item)
            {
                if (kv.Value == null) continue;
                if (!colNames.Contains(kv.Name.ToUpper())) continue;
                if (kv.Value.GetType() == typeof(JArray) || kv.Value.GetType() == typeof(JObject))
                {
                    if ("level" == kv.Name)
                    {
                        newObj["\"" + kv.Name.ToUpper() + "\""] = Regex.Replace(kv.Value.ToString(), @"\r\n?|\n", "");
                    }
                    else
                        newObj[kv.Name.ToUpper()] = Regex.Replace(kv.Value.ToString(), @"\r\n?|\n", "");
                }
                else if (kv.Value.Value is bool)
                {
                    newObj[kv.Name.ToUpper()] = kv.Value.Value ? "1" : "0";
                }
                else
                    newObj[kv.Name.ToUpper()] = kv.Value.Value;
            }
            return e;
        }

        public static bool IsDev = false;
        public static string convert8859p1togb2312(string s)
        {
            if (IsDev) return s;
            return System.Text.Encoding.Default.GetString(System.Text.Encoding.GetEncoding("iso-8859-1").GetBytes(s));
        }
        public static string convertgb2312to8859p1(string s)
        {
            if (IsDev) return s;
            return System.Text.Encoding.GetEncoding("iso-8859-1").GetString(System.Text.Encoding.Default.GetBytes(s));
        }
    }
}