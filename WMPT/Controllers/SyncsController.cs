using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using WMPT.Infrastructure;
using WMPT.Models;

namespace WMPT.Controllers
{
    public class SyncsController : ApplicationController
    {


        public dynamic Get()
        {
            try
            {
                var request = System.Web.HttpUtility.ParseQueryString(Request.RequestUri.Query);
                
                var syncs = new Syncs().Paged(sql: @"SELECT wmsync.*,
       WMGZH.NAME PNAME,
       DECODE (wmsync.synctype,
               '0', '0 - Upload',
               '1', '1 - Download',
               wmsync.synctype)
          TYPE,
 DECODE (wmsync.status,
               -1, 'fail',
               0, 'Begin',
               1,'Success',
               wmsync.status)
          STATUSDESC
  FROM wmsync LEFT JOIN WMGZH ON WMGZH.PID = wmsync.pid", primaryKey:"ID", orderBy: "ID DESC", currentPage: int.Parse(request["currentpage"]), pageSize: int.Parse(request["pagesize"]));

                return new { status = 1, syncs };
            }
            catch (Exception ex)
            {

                return new { status = 0, message = ex.Message };
            }


        }



    }
}
