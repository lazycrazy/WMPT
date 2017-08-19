using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WMPT.Infrastructure;

namespace WMPT.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            using (var sr = new StreamReader(Server.MapPath("~/Views/22.html")))
            {
                String htmlContent = sr.ReadToEnd();
                return Content(htmlContent);
            }

        }
    }
}
