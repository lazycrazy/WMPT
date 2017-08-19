﻿using System;
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
using WMPT.Infrastructure.Job;
using WMPT.Models;
using System.Linq;

namespace WMPT.Controllers
{
    public class StartSchedulerController : ApplicationController
    {
        public dynamic Post()
        {
            try
            {
                JobScheduler.Start();
                return new { status = 1 };
            }
            catch (Exception ex)
            {
                Logger.LogError(ex);
                return new { status = 0, message = "开始任务计划失败" };
            }
        }


    }
}
