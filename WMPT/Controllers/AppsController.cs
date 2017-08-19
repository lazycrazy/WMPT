using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using WMPT.Infrastructure;
using WMPT.Models;

namespace WMPT.Controllers
{
    public class AppsController : ApplicationController
    {


        public dynamic Get()
        {
            try
            {
                var apps = Massive.DB.Current.Query(@"SELECT ID,
       APPID,
       CLIENT_ID,
       NAME
  FROM WMAPPS").ToList();
                foreach (var app in apps)
                { 
                    app.authorizeURL = string.Format(Urls.ShouQuan, app.CLIENT_ID, Urls.redirect_uri);
                }
                return new { status = 1, apps };
            }
            catch (Exception ex)
            {

                return new { status = 0, message = ex.Message };
            }


        }



    }
}
