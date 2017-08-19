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
    public class UploadMemberJob : IJob
    {
        public ILogger Logger = new NLogger();

        public void Execute(IJobExecutionContext context)
        {
            try
            {
                JobDataMap dataMap = context.JobDetail.JobDataMap;
                var pid = dataMap.GetString("pid");
                WMHelper.UploadMember(pid).Wait();

                //Logger.LogInfo("上传会员Job执行成功");
                //job成功日志
            }
            catch (Exception ex)
            {
                Logger.LogError("上传会员Job执行失败");
                Logger.LogError(ex);
                //job失败日志
            }


        }
    }
}