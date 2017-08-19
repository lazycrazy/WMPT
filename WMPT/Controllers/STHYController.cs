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

namespace WMPT.Controllers
{
    public class STHYController : ApplicationController
    {
        private string url = @"https://dopen.weimob.com/api/1_0/KLDService/KLDMemberCard/GetOffLineMemberInfoPageListAndTotal?accesstoken=7adc14a0-abb0-4d5d-b5dc-928f9a2dbc50";

        public STHYController()
        {

        }



        public async Task<dynamic> Get()
        {
            Logger.LogDebug("enter");
            try
            {

                var request = (HttpWebRequest)WebRequest.Create(url);
                request.Method = "POST";
                request.ContentType = "application/json";
                var postDataStr = JsonConvert.SerializeObject(new
                {
                    pageIndex = 1,
                    pageSize = 20
                });
                request.ContentLength = Encoding.UTF8.GetByteCount(postDataStr);
                using (var reqStream = request.GetRequestStream())
                {
                    reqStream.Write(Encoding.UTF8.GetBytes(postDataStr), 0, (int)request.ContentLength);
                }


                var response = await request.GetResponseAsync();

                var myResponseStream = response.GetResponseStream();
                StreamReader myStreamReader = new StreamReader(myResponseStream, Encoding.GetEncoding("utf-8"));
                string retString = myStreamReader.ReadToEnd();
                myStreamReader.Close();
                myResponseStream.Close();
                return new { status = 1, retString };

            }
            catch (Exception ex)
            {
                Logger.LogError(ex);
                throw;
            }
        }




    }
}
