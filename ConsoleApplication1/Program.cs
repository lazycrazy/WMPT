using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Massive;
using Newtonsoft.Json.Linq;
using System.Data;
using WMPT.Infrastructure;
using WMPT.Models;

namespace ConsoleApplication1
{
    class Program
    {
        static void Main(string[] args)
        {
            var queryParam = new
            {
                begintime = WMHelper.GetTimeStamp(DateTime.Now.Date.AddDays(-7)),
                pageIndex = 1,
                pageSize = 100,
                isOnlyEffective = false
            };
            var syncs = new Syncs();

            WMHelper.AddWmMemberPointLogs(123, "456", queryParam, syncs).Wait();

            //var data = rs.GetType().GetProperty("data");

            {

            }
            //var queryParam = new { memberCardNo = "17713222813" };

            //var url = string.Format(Urls.GetPointsLogPageListAndTotal, "15d74508-abc6-4758-aeae-811c929da2a7");
            //dynamic rs =   WMHelper.PostJson(url, queryParam).Result;

            //var abc = JObject.Parse("{\"returnCode\":\"null00003\",\"returnMsg\":\"请求异常\"}");
            //var queryParam = new { memberCardNo = "13700386142" };
            //var url = "https://dopen.weimob.com/api/1_0/KLDService/KLDMemberCard/GetMemberInfo?accesstoken=72f3bfc6-0d92-415b-8289-c1729b94628b";
            //dynamic rss = WMHelper.PostJson(url, queryParam).Result;



            Console.ReadLine();
            //var db = Massive.DB.Current;
            //using (var conn = db.OpenConnection())
            //{
            //    using (var cmd = conn.CreateCommand())
            //    {
            //        cmd.CommandText = "PRC_Wmmember_IMPORT";
            //        cmd.CommandType = CommandType.StoredProcedure;
            //        var param = cmd.CreateParameter();
            //        param.ParameterName = "V_PID";
            //        param.Value = "4";
            //        param.DbType = DbType.String;
            //        var oparam = cmd.CreateParameter();
            //        oparam.ParameterName = "OUTSTATUS";
            //        oparam.Direction = ParameterDirection.Output;
            //        oparam.DbType = DbType.Int32;
            //        cmd.Parameters.Add(param);
            //        cmd.Parameters.Add(oparam);
            //        cmd.ExecuteNonQuery();
            //        if (int.Parse(cmd.Parameters["OUTSTATUS"].Value.ToString()) != 0)
            //        { }
            //    }
            //    conn.Close();
            //}


            ////测试获取会员
            //var strJSON =
            //@"{""data"":{""qrCodeUrl"":""http://shopimg.weimob.com/670/MemberCardNoQrCode/320_320/784d7307-f7bf-4fb9-8391-326308941604.jpg"",""barCodeUrl"":""http://shopimg.weimob.com/670/MemberCardNoBarCode/240_80/c59ff736-62a3-4473-ac07-9913e259fbcc.jpg"",""fromType"":0,""fromValue"":null,""weiChatcode"":null,""isNeedSyncWeiXin"":false,""passWord"":null,""level"":{""Key"":1,""Value"":""白银会员""},""memberStatus"":1,""canUseStoreType"":1,""canUseStoreIds"":[24,26,23],""id"":70,""aId"":670,""openId"":""o1_96s6ilpc8Dt__0pWqlYvBSZdQ"",""weimobopenId"":""o1_96s6ilpc8Dt__0pWqlYvBSZdQ"",""memberCardNo"":""13651614940"",""name"":""曾楠"",""nickName"":null,""headUrl"":"""",""phone"":""13651614940"",""sex"":0,""birthday"":null,""eMail"":null,""degree"":0,""profession"":0,""income"":0,""hobby"":null,""listOther"":null,""addressInfo"":{""provinceName"":"""",""provinceId"":null,""cityName"":"""",""cityId"":null,""districtName"":"""",""districtId"":null,""address"":null,""mapType"":0,""longitude"":0,""latitude"":0,""code"":null},""growthValue"":0,""points"":111084978,""amount"":9350.58,""allConsumingAmount"":608.95,""balanceConsumingAmount"":340.09,""consumingCount"":10,""perConsumingAmount"":60.9,""allPoints"":111112063,""lastConsumingTime"":""1478158384"",""activateTime"":1477470997,""disCount"":50,""tags"":null,""entityStatus"":1,""startDate"":0,""expireDate"":0,""expireDateType"":0,""birthdayMonth"":0,""birthdayDay"":0},""code"":{""errcode"":""0"",""errmsg"":null}}";
            //dynamic rs = JObject.Parse(strJSON);
            //if ("0" != rs.code.errcode.Value.ToString())
            //{
            //    //log err
            //    return;
            //}
            //var item = rs.data;


            //dynamic e = new ExpandoObject();
            //var newObj = (IDictionary<string, object>)e;
            //var wMMembers = new DynamicModel("HYDB", "WMMEMBER");

            //var colNames =
            //    wMMembers.Query(@"SELECT column_name   FROM USER_TAB_COLUMNS WHERE TABLE_NAME = :0",
            //                    args: wMMembers.TableName).Select(c => c.COLUMN_NAME).ToList();
            //foreach (var kv in item)
            //{
            //    if (kv.Value == null) continue;
            //    if (!colNames.Contains(kv.Name.ToUpper())) continue;
            //    if (kv.Value.GetType() == typeof(JArray) || kv.Value.GetType() == typeof(JObject))
            //    {
            //        if ("level" == kv.Name)
            //        {
            //            newObj["\"" + kv.Name.ToUpper() + "\""] = kv.Value.ToString();
            //        }
            //        else
            //            newObj[kv.Name.ToUpper()] = kv.Value.ToString();
            //    }
            //    else if (kv.Value.Value is bool)
            //    {
            //        newObj[kv.Name.ToUpper()] = kv.Value.Value ? "1" : "0";
            //    }

            //    else
            //        newObj[kv.Name.ToUpper()] = kv.Value.Value;
            //}

            //{

            //    e.SYNCID = 123;
            //    e.PID = "xxxxx";
            //}

            //wMMembers.Insert(e);

            //string ab;

            ////测试  获取积分
            //dynamic rs = JObject.Parse(@"{""data"":{""totalCount"":1,""items"":[{""id"":311,""memberCardNo"":""111111100000136123"",""name"":""Sara"",""title"":""会员签到赠送积分"",""phone"":""13323339201"",""storeId"":0,""storeName"":"""",""points"":0,""time"":1488951604,""pointsPayType"":7,""addOrReduce"":0,""operataor"":""卡号：111111100000136123"",""remark"":""会员签到赠送积分""}]},""code"":{""errcode"":0,""errmsg"":null}}");
            //var a = ("0" != rs["code"].Value<string>("errcode"));
            //dynamic items = rs.data.items;
            //var points = new List<dynamic>();
            //var ids = new List<dynamic>();
            //foreach (dynamic item in items)
            //{
            //    var id = item.id.Value;
            //    dynamic e = new ExpandoObject();
            //    var newObj = (IDictionary<string, object>)e;
            //    foreach (var kv in item)
            //    {
            //        newObj[kv.Name.ToUpper()] = kv.Value.Value;
            //    }
            //    ids.Add(item.id.Value);
            //    points.Add(e);
            //}
            //var wMPointLogs = new DynamicModel("HYDB", "WMPOINTSLOG");
            //var strIds = string.Join(",", ids);
            //var existsIds = wMPointLogs.Query("select id from WMPOINTSLOG where id in (:0) and pid=:1", args: new object[] { strIds, "43434" }).Select(d => (long)d.ID).ToList();
            //var addPoints = points.Where(p => existsIds.Exists(e => e == p.ID)).ToArray();


            //string syncType = "0";
            //dynamic syncs = new DynamicModel("HYDB", "WMSYNC", "ID", "", "WMSYNC_ID_SEQ");
            //var newSync = syncs.First(SYNCTYPE: syncType, Columns: "SYNCTIME", OrderBy: "ID DESC");
            //DateTime abc;
            //if (newSync == null)
            //    abc = DateTime.Parse("2017-08-01");
            //abc = newSync.SYNCTIME;

            ////var app = Massive.DB.Current.Query(@"SELECT  *  FROM WMAPPS where id=:0", 1).ToList();

            //dynamic gzhs = new DynamicModel("HYDB", "WMGZH", "PID");
            //var gzh = gzhs.First(PID: "56009512");
            //var asscess_token = gzh.ACCESS_TOKEN;

            ////添加同步号
            //syncs = new DynamicModel("HYDB", "WMSYNC", "ID", "", "WMSYNC_ID_SEQ");
            //newSync = syncs.SaveAsNew(new { PID = "56009512", SYNCTYPE = "0", SYNCTIME = "sysdate", EFFECTMEMBERCOUNT = 0 });

        }
    }
}
