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
        public ILogger Logger = new NLogger();

        public void Execute(IJobExecutionContext context)
        {

            try
            {
                JobDataMap dataMap = context.JobDetail.JobDataMap;
                var pid = dataMap.GetString("pid");
                WMHelper.RefreshToken(pid).Wait();


                //Logger.LogInfo("刷新Token Job成功");
                //job成功日志
            }
            catch (Exception ex)
            {
                Logger.LogError("刷新Token Job失败");
                Logger.LogError(ex);
                //job失败日志
            }


        }
    }
}