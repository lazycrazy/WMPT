using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Globalization;
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
    public class DownloadMemberController : ApplicationController
    {
        public async Task<dynamic> Post(dynamic data)
        {

            try
            {
                string pid = data.PID;
                await WMHelper.DownloadMember(pid);

                return new { status = 1 };

            }
            catch (Exception ex)
            {


                Logger.LogError(ex);
                return new { status = 0, message = "下载会员失败" };
            }
        }


    }
}
