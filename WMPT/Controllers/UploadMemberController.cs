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
    public class UploadMemberController : ApplicationController
    {
        public async Task<dynamic> Post(dynamic data)
        {
            try
            {
                string pid = data.PID;
                await WMHelper.UploadMember(pid);


                return new { status = 1 };
            }
            catch (Exception ex)
            {
                Logger.LogError(ex);
                return new { status = 0, message = "上传会员失败" };
            }
        }

    }
}
