using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using WMPT.Infrastructure;
using WMPT.Models;
using System.Linq;

namespace WMPT.Controllers
{
    public class AuthorizeController : ApplicationController
    {
        public async Task<dynamic> Post(dynamic data)
        {
            try
            {
                int id = data.id;
                var app = Massive.DB.Current.Query(@"SELECT  *  FROM WMAPPS where id=:0", id);
                var apps = app.ToList();
                var url = string.Format(Urls.GetAccessToken, data.code, apps[0].CLIENT_ID, apps[0].CLIENT_SECRET, Urls.redirect_uri);

                var rs = await WMHelper.RequestUrl(url, "POST");
                var gzh = new Gzhs();
                if (gzh.Count("", "PID=:0", rs.public_account_id.Value) == 0)
                {
                    gzh.Insert(
                        new
                            {
                                ACCESS_TOKEN = rs.access_token.Value,
                                REFRESH_TOKEN = rs.refresh_token.Value,
                                CLIENT_ID = apps[0].CLIENT_ID,
                                PID = rs.public_account_id.Value
                            });
                    url = string.Format(Urls.GetWMUserInfo, rs.access_token.Value);
                    rs = await WMHelper.RequestUrl(url, "GET");
                    gzh.Save(new { PID = rs.data.pid.Value, NAME = rs.data.name.Value, AVATARURL = rs.data.avatarUrl.Value });
                }
                else
                    gzh.Save(new { PID = rs.public_account_id.Value, ACCESS_TOKEN = rs.access_token.Value, REFRESH_TOKEN = rs.refresh_token.Value });


                return new { status = 1 };
            }
            catch (Exception ex)
            {
                Logger.LogError(ex);
                return new { status = 0, message = "微盟公众号授权失败" + ex.Message };
            }
        }


    }
}
