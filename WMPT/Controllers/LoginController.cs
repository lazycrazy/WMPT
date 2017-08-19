using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WMPT.Infrastructure;
using WMPT.Models;

namespace WMPT.Controllers
{
    public class LoginController : AccountController
    {

        [AllowAnonymous]
        public dynamic Post(dynamic data)
        {
            dynamic result = _users.Login(name: data.username.ToString(), password: data.password.ToString());
            if (result.Authenticated)
            {
                SetToken(result.User);
                return new { status = 1, message = "登录成功", user = new { id = result.User.ID, name = result.User.NAME, avatar = "bullet.png" } };
            }

            return new { status = 0, message = result.Message };
        }


    }
}
