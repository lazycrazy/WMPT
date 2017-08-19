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
    public class DownloadMemberJob : IJob
    {
        public ILogger Logger = new NLogger();

        public void Execute(IJobExecutionContext context)
        {
            try
            {
                JobDataMap dataMap = context.JobDetail.JobDataMap;
                var pid = dataMap.GetString("pid");
                WMHelper.DownloadMember(pid).Wait();


                //Logger.LogInfo("下载会员Job执行成功");
                //job成功日志
            }
            catch (Exception ex)
            {
                Logger.LogError("下载会员Job执行失败");
                Logger.LogError(ex);
                //job失败日志
            }
        }
    }
}