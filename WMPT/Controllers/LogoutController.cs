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
    public class LogoutController : AccountController
    {


        public override dynamic Get()
        {
            FormsAuthentication.SignOut();
            HttpContext.Current.Response.Cookies["auth"].Value = null;
            HttpContext.Current.Response.Cookies["auth"].Expires = DateTime.Today.AddDays(-1);
            if (CurrentUser != null)
            {
                _users.SetToken("", CurrentUser);
            }
            return new { status = 1 };
        }



    }
}
