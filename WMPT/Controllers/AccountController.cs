using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WMPT.Infrastructure;
using WMPT.Models;

namespace WMPT.Controllers
{
    public class AccountController : ApplicationController
    {
        protected Users _users;

        public AccountController()
        {
            _users = new Users();
        }

        protected void SetToken(dynamic user)
        {
            var token = Guid.NewGuid().ToString();
            _users.SetToken(token, user);
            TokenStore.SetClientAccess(token);
        }
        
        public virtual dynamic Get()
        {
            if (CurrentUser != null)
            {
                var user = new { id = CurrentUser.ID, avatar = "bullet.png" };
                return new { status = 1, user };
            }
            return new { status = 0 };
        }




    }
}
