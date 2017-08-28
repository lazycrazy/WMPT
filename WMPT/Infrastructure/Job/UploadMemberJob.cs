using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Quartz;
using WMPT.Infrastructure.Logging;
using WMPT.Models;
using System.Threading;

namespace WMPT.Infrastructure.Job
{
    [DisallowConcurrentExecution]
    public class UploadMemberJob : IJob
    {
        public NLog.Logger Logger = NLog.LogManager.GetCurrentClassLogger();

        public void Execute(IJobExecutionContext context)
        {
            Thread.CurrentThread.IsBackground = true;
            JobDataMap dataMap = context.JobDetail.JobDataMap;
            var pid = dataMap.GetString("pid");

            try
            {
                WMHelper.UploadMember(pid).Wait();

                //Logger.LogInfo("上传会员Job执行成功");
                //job成功日志
            }
            catch (Exception ex)
            {
                Logger.Error("公众号：" + pid + "上传会员Job执行失败");
                Logger.Error(ex);
                //job失败日志
            }


        }
    }
}