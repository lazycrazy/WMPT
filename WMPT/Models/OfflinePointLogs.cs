﻿using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using Massive;
using WMPT.Infrastructure;

namespace WMPT.Models
{
    public class OfflinePointLogs : DynamicModel
    {
        public OfflinePointLogs()
            : base("HYDB", "WMOFFLINEPOINTSLOG")
        {

        }
    }
}