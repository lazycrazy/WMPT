using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using Massive;

namespace WMPT.Models
{
    public class Gzhs : DynamicModel
    {
        public Gzhs()
            : base("HYDB", "WMGZH", "PID", "")
        {

        }

        //public static string GetAccessToken(string pid)
        //{
        //    dynamic gzhs = new Gzhs();
        //    var accessToken = gzhs.First(PID: pid, Columns: "ACCESS_TOKEN").ACCESS_TOKEN;
        //    return accessToken;
        //}
    }
}