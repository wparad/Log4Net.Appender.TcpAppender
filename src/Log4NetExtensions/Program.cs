using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using log4net.Appender;
using log4net.Core;

namespace Log4NetExtensions
{
    public class TcpAppender : AppenderSkeleton
    {
        static void Main(string[] args)
        {

        }

        protected override void Append(LoggingEvent loggingEvent)
        {
            throw new NotImplementedException();
        }
    }
}
