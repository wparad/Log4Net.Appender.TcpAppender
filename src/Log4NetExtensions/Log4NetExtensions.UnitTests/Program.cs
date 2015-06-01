using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using log4net;
using log4net.Appender;

namespace Log4NetExtensions.UnitTests
{
    public class Program
    {
        public static void Main()
        {
            SetupTcp();

            var serializer = new JavaScriptSerializer();
            Thread.Sleep(2);
            var tasks = new int[20].Select((_, index) => Task.Factory.StartNew(() =>
            {
                var logger = LogManager.GetLogger(string.Format("Logger: {0}", index));
                for (var loop = 0; loop < 10000; loop++)
                {
                    logger.Info(serializer.Serialize(new
                    {
                      Type = "Log4NetExtensions.UnitTests",
                      Loop = loop,
                      Index = index
                    }));
                    Thread.Sleep(1);
                }
            }));
            Task.WaitAll(tasks.ToArray());
        }

        public static void SetupUdp()
        {
            var layout = new log4net.Layout.PatternLayout();
            //var appender = new TcpAppender(5140, IPAddress.Loopback) { Layout = layout};
            var appender = new UdpAppender{ Layout = layout, RemoteAddress = IPAddress.Loopback, RemotePort = 5142};
            layout.ActivateOptions();
            appender.ActivateOptions();

            var layout2 = new log4net.Layout.PatternLayout();
            //var appender = new TcpAppender(5140, IPAddress.Loopback) { Layout = layout};
            var appender2 = new UdpAppender{ Layout = layout2, RemoteAddress = IPAddress.Loopback, RemotePort = 5142};
            layout2.ActivateOptions();
            appender2.ActivateOptions();

            var layout3 = new log4net.Layout.PatternLayout();
            //var appender = new TcpAppender(5140, IPAddress.Loopback) { Layout = layout};
            var appender3 = new UdpAppender{ Layout = layout3, RemoteAddress = IPAddress.Loopback, RemotePort = 5142};
            layout3.ActivateOptions();
            appender3.ActivateOptions();

            log4net.Config.BasicConfigurator.Configure(appender, appender2, appender3);
        }

        public static void SetupTcp()
        {
            var layout = new log4net.Layout.PatternLayout();
            var appender = new TcpAppender{ RemotePort = 5140, Layout = layout };
            layout.ActivateOptions();
            appender.ActivateOptions();

            var layout2 = new log4net.Layout.PatternLayout();
            var appender2 = new TcpAppender{ RemotePort = 5140, Layout = layout2 };
            layout2.ActivateOptions();
            appender2.ActivateOptions();

                var layout3 = new log4net.Layout.PatternLayout();
            var appender3 = new TcpAppender{ RemotePort = 5140, Layout = layout3 };
            layout3.ActivateOptions();
            appender3.ActivateOptions();

            log4net.Config.BasicConfigurator.Configure(appender, appender2, appender3);
        }
    }
}
