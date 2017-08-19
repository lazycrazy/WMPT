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
    public class GzhsController : ApplicationController
    {


        public dynamic Get()
        {
            try
            {
                var gzhs = Massive.DB.Current.Query("select * from wmgzh").ToList();
                
                return new { status = 1, gzhs };
            }
            catch (Exception ex)
            {

                return new { status = 0, message = ex.Message };
            }


        }



    }
}
