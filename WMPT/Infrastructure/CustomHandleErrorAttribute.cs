using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web;
using System.Web.Http.Filters;
using Newtonsoft.Json;
using WMPT.Infrastructure.Logging;

namespace WMPT.Infrastructure
{
    public class CustomHandleErrorAttribute : ExceptionFilterAttribute
    {
        private static readonly ILogger logger = new NLogger();
        public override void OnException(HttpActionExecutedContext actionExecutedContext)
        {
            var status = -1;
            var message = "服务器异常，请求失败!请联系管理员";
            //获取action的请求参数
            //var requestParameters = JsonHelper.SerializeObject(actionExecutedContext.ActionContext.ActionArguments.Values);
            actionExecutedContext.Response = GetResponseMessage(status, message);
            logger.LogError(actionExecutedContext.Exception);
        }
        private HttpResponseMessage GetResponseMessage(int status, string message)
        {
            var resultModel = new ApiModelsBase() { Status = status, Message = message };

            return new HttpResponseMessage()
            {
                Content = new ObjectContent<ApiModelsBase>(
                    resultModel,
                    new JsonMediaTypeFormatter(),
                    "application/json"
                    )
            };
        }
        internal class ApiModelsBase
        {
            public int Status { get; set; }
            public string Message { get; set; }
        }
    }
    public class JsonHelper
    {
        /// <summary>
        /// 将对象序列化为JSON格式
        /// </summary>
        /// <param name="o">对象</param>
        /// <returns>json字符串</returns>
        public static string SerializeObject(object o)
        {
            string json = JsonConvert.SerializeObject(o);
            return json;
        }

        /// <summary>
        /// 解析JSON字符串生成对象实体
        /// </summary>
        /// <typeparam name="T">对象类型</typeparam>
        /// <param name="json">json字符串(eg.{"ID":"112","Name":"石子儿"})</param>
        /// <returns>对象实体</returns>
        public static T DeserializeJsonToObject<T>(string json) where T : class
        {
            JsonSerializer serializer = new JsonSerializer();
            StringReader sr = new StringReader(json);
            object o = serializer.Deserialize(new JsonTextReader(sr), typeof(T));
            T t = o as T;
            return t;
        }

        /// <summary>
        /// 解析JSON数组生成对象实体集合
        /// </summary>
        /// <typeparam name="T">对象类型</typeparam>
        /// <param name="json">json数组字符串(eg.[{"ID":"112","Name":"石子儿"}])</param>
        /// <returns>对象实体集合</returns>
        public static List<T> DeserializeJsonToList<T>(string json) where T : class
        {
            JsonSerializer serializer = new JsonSerializer();
            StringReader sr = new StringReader(json);
            object o = serializer.Deserialize(new JsonTextReader(sr), typeof(List<T>));
            List<T> list = o as List<T>;
            return list;
        }

        /// <summary>
        /// 反序列化JSON到给定的匿名对象.
        /// </summary>
        /// <typeparam name="T">匿名对象类型</typeparam>
        /// <param name="json">json字符串</param>
        /// <param name="anonymousTypeObject">匿名对象</param>
        /// <returns>匿名对象</returns>
        public static T DeserializeAnonymousType<T>(string json, T anonymousTypeObject)
        {
            T t = JsonConvert.DeserializeAnonymousType(json, anonymousTypeObject);
            return t;
        }
    }
}