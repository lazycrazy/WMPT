using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Common.Logging.Configuration;
using Common.Logging.NLog;
using Quartz;
using Quartz.Impl;
using WMPT.Models;
using System.Threading.Tasks;

namespace WMPT.Infrastructure.Job
{
    public class JobScheduler
    {
        public volatile static IScheduler scheduler;
        public static void Start()
        {
            if (scheduler != null) return;
            var config = new NameValueCollection();
            var adaptor = new NLogLoggerFactoryAdapter(config);
            Common.Logging.LogManager.Adapter = adaptor;
            scheduler = StdSchedulerFactory.GetDefaultScheduler();
            scheduler.Start();
            var gzhs = new Gzhs();
            var pids = gzhs.All(columns: "PID").Select(g => g.PID).ToArray();

            foreach (string pid in pids)
            {
                //await WMHelper.RefreshToken(pid);
                ITrigger triggerRefresh = TriggerBuilder.Create()
                  .StartNow().WithSimpleSchedule
                    (s =>
                       s.WithIntervalInMinutes(10)
                      .RepeatForever()
                    )
                  .Build();
                IJobDetail job = JobBuilder.Create<RefreshTokenJob>().WithIdentity("刷新token公众号：" + pid, "RefreshToken").UsingJobData("pid", pid).Build();

                scheduler.ScheduleJob(job, triggerRefresh);
            }

            foreach (string pid in pids)
            {
                ITrigger triggerUpload = TriggerBuilder.Create()
                 .WithSimpleSchedule
                   (s =>
                      s.WithIntervalInMinutes(1)
                     .RepeatForever()
                   )
                 .Build();
                IJobDetail job = JobBuilder.Create<UploadMemberJob>().WithIdentity("上传会员，公众号：" + pid, "UploadMember").UsingJobData("pid", pid).Build();

                scheduler.ScheduleJob(job, triggerUpload);
            }

            foreach (string pid in pids)
            {
                ITrigger triggerDownload = TriggerBuilder.Create()
                  .WithSimpleSchedule
                    (s =>
                       s.WithIntervalInMinutes(1)
                      .RepeatForever()
                    )
                  .Build();
                IJobDetail job = JobBuilder.Create<DownloadMemberJob>().WithIdentity("下载会员，公众号：" + pid, "DownloadMember").UsingJobData("pid", pid).Build();

                scheduler.ScheduleJob(job, triggerDownload);
            }
        }

        public static void Stop()
        {
            if (scheduler == null) return;
            scheduler.Shutdown();
            //scheduler.Clear();
            scheduler = null;
        }
    }
}