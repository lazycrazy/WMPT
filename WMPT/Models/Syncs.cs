using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using Massive;

namespace WMPT.Models
{
    public class Syncs : DynamicModel
    {
        public Syncs()
            : base("HYDB", "WMSYNC", "ID", "", "WMSYNC_ID_SEQ")
        {

        }
        public void AddEffectCount(int syncId, int count)
        {
            this.Execute("update WMSYNC set EFFECTMEMBERCOUNT=EFFECTMEMBERCOUNT+:1 where ID=:0", syncId, count);
        }
        public int New(string pid, string syncType)
        {
            var newSync = this.Insert(new { PID = pid, SYNCTYPE = syncType, SYNCTIME = "sysdate", EFFECTMEMBERCOUNT = 0, STATUS = 0 });
            return newSync.ID;
        }
        public void SetSuccess(int id)
        {
            this.Update(new { STATUS = 1 }, "ID=:0 and STATUS=0", id);
        }
        public void SetError(int id)
        {
            this.Update(new { STATUS = -1 }, "ID=:0 and STATUS=0", id);
        }
        public static DateTime GetLastBeginTime(string syncType, string pid)
        {
            dynamic syncs = new Syncs();
            var newSync = syncs.First(SYNCTYPE: syncType, STATUS: 1, PID: pid, Columns: "SYNCTIME", OrderBy: "ID DESC");
            if (newSync == null)
                return DateTime.Parse("2017-08-01");
            return newSync.SYNCTIME.AddMinutes(-10);
        }
    }
}