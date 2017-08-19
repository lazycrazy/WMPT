using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using Quartz;
using Quartz.Impl;
using WMPT.Infrastructure;
using WMPT.Infrastructure.Job;

namespace WMPT
{
    // 注意: 有关启用 IIS6 或 IIS7 经典模式的说明，
    // 请访问 http://go.microsoft.com/?LinkId=9394801

    public class WebApiApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            //Environment.SetEnvironmentVariable("ORA_TZFILE", null);
            //Environment.SetEnvironmentVariable("NLS_LANG",
            //                                   "CHINESE_CHINA.WE8ISO8859P1", EnvironmentVariableTarget.Process);
            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configuration.IncludeErrorDetailPolicy = IncludeErrorDetailPolicy.Always;

            WebApiConfig.Register(GlobalConfiguration.Configuration);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
            //GlobalConfiguration.Configuration.Filters.Add(new CustomHandleErrorAttribute());


        }


    }
}