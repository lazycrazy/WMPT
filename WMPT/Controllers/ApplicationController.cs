using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using WMPT.Infrastructure;
using WMPT.Infrastructure.Logging;

namespace WMPT.Controllers
{
    [WebApiAuth]
    public class ApplicationController : ApiController
    {
        public ITokenHandler TokenStore;
        public ILogger Logger;

        public ApplicationController(ITokenHandler tokenStore, ILogger logger)
        {
            TokenStore = tokenStore;
            Logger = logger;
        }
        public ApplicationController(ITokenHandler tokenStore)
            : this(tokenStore, new NLogger())
        {
        }
        public ApplicationController()
            : this(new FormsAuthTokenStore(), new NLogger())
        {
        }
        dynamic _currentUser;
        public dynamic CurrentUser
        {
            get
            {
                var token = TokenStore.GetToken();
                if (!String.IsNullOrEmpty(token))
                {
                    _currentUser = Models.Users.FindByToken(token);

                    if (_currentUser == null)
                    {
                        //force the current user to be logged out...
                        TokenStore.RemoveClientAccess();
                    }
                }

                //Hip to be null...
                return _currentUser;
            }

        }
        public bool IsLoggedIn
        {
            get
            {
                return CurrentUser != null;
            }
        }
    }
}
