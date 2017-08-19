using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.Http.Filters;
using System.Web.Mvc;
using Newtonsoft.Json;
using WMPT.Controllers;
using ActionFilterAttribute = System.Web.Mvc.ActionFilterAttribute;

namespace WMPT.Infrastructure
{
    public class WebApiAuthAttribute : AuthorizationFilterAttribute
    {
        public override void OnAuthorization(System.Web.Http.Controllers.HttpActionContext actionContext)
        {


            var attributes = actionContext.ActionDescriptor.GetCustomAttributes<AllowAnonymousAttribute>().OfType<AllowAnonymousAttribute>();
            bool isAnonymous = attributes.Any(a => a is AllowAnonymousAttribute);
            if (isAnonymous) return;


            var controller = actionContext.ControllerContext.Controller as ApplicationController;

            if (controller == null || !controller.IsLoggedIn)
            {
                actionContext.Response = new HttpResponseMessage() { Content = new StringContent(JsonConvert.SerializeObject(new { status = 0, message = "Unauthorized" }), Encoding.UTF8, "application/json") };

                return;
            }
        }
    }
    public class RequireAdminAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {

            dynamic controller = filterContext.Controller;

            //user logged in?
            if (!controller.IsLoggedIn)
            {
                if (filterContext.RequestContext.HttpContext.Request.ContentType == "application/json")
                    filterContext.Result = new JsonResult() { Data = "Unauthorized" };
                else
                    filterContext.Result = new HttpUnauthorizedResult();
                return;
            }

            //is the user an admin?
            var adminEmails = new string[] { "lazycrazy@live.cn" };
            string userEmail = controller.CurrentUser.Email;
            if (!adminEmails.Contains(userEmail))
            {
                //DecideResponse(filterContext.HttpContext);
                if (filterContext.RequestContext.HttpContext.Request.ContentType == "application/json")
                    filterContext.Result = new JsonResult() { Data = "Unauthorized" };
                else
                    filterContext.Result = new HttpUnauthorizedResult();
                //filterContext.Result = new RedirectResult("/account/logon");

                return;
            }

        }
        void DecideResponse(HttpContextBase ctx)
        {
            if (ctx.Request.ContentType == "application/json")
            {
                ctx.Response.Write("Unauthorized");
            }
            else
            {

                ctx.Response.Redirect("/account/logon");
            }
            ctx.Response.End();
        }
    }


}