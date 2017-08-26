using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Quartz;
using WMPT.Infrastructure.Logging;
using WMPT.Models;

namespace WMPT.Infrastructure.Job
{
    [DisallowConcurrentExecution]
    public class RefreshTokenJob : IJob
    {
        public NLog.Logger Logger = NLog.LogManager.GetCurrentClassLogger();

        public void Execute(IJobExecutionContext context)
        {
            JobDataMap dataMap = context.JobDetail.JobDataMap;
            var pid = dataMap.GetString("pid");

            try
            {
                WMHelper.RefreshToken(pid).Wait();


                //Logger.LogInfo("刷新Token Job成功");
                //job成功日志
            }
            catch (Exception ex)
            {
                Logger.Error("公众号：" + pid + "刷新Token Job失败");
                Logger.Error(ex);

                //job失败日志
            }


        }
    }
}