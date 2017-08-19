using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WMPT.Infrastructure;
using WMPT.Models;

namespace WMPT.Controllers
{
    public class RegisterController : AccountController
    {

        [AllowAnonymous]
        public dynamic Post(dynamic data)
        {
            dynamic result = _users.Register(name: data.username.ToString(), password: data.password.ToString(), confirm: data.confirm.ToString());
            if (result.Success)
            {
                SetToken(result.User);
                return new { Status = 1 };
            }

            return new { status = 0, result.Message };
        }


    }
}
