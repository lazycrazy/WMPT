using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WMPT.Infrastructure.Logging
{
    public interface ILogger
    {
        void LogDebug(string message);
        void LogError(Exception x);
        void LogError(string message);
        void LogFatal(Exception x);
        void LogFatal(string message);
        void LogInfo(string message);
        void LogWarning(string message);
    }
}