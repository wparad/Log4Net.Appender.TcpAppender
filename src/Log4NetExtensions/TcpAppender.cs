using System;
using System.Globalization;
using System.Net;
using System.Net.Sockets;
using System.Text;
using log4net.Appender;
using log4net.Core;
using log4net.Util;

namespace Log4NetExtensions 
{
	public class TcpAppender : AppenderSkeleton
	{
	    public IPAddress RemoteAddress { get; set; }
	    public int RemotePort { get; set; }
	    public Encoding Encoding { get; set; }
	    protected TcpClient Client { get; set; }

		public override void ActivateOptions()
		{
			base.ActivateOptions();

            try
            {
                Client = new TcpClient();
                Client.Connect(RemoteAddress, RemotePort);
            }
			catch (Exception ex) 
			{
				ErrorHandler.Error("Could not initialize the TcpClient.", ex, ErrorCode.GenericFailure);
				Client = null;
			}
		}

		protected override void Append(LoggingEvent loggingEvent) 
		{
			try 
		    {
                //The remote can close the connection, in that case it should be reopened.
		        if (!Client.Connected) { Client.Connect(RemoteAddress, RemotePort);}
		        var buffer = Encoding.GetBytes(RenderLoggingEvent(loggingEvent).ToCharArray());
			    Client.GetStream().Write(buffer, 0, buffer.Length);
			} 
			catch (Exception ex) 
			{
				ErrorHandler.Error(string.Format("Unable to send logging event to remote host {0} on port {1}.",
                    RemoteAddress, RemotePort), ex,  ErrorCode.WriteFailure);
			}
		}

		override protected bool RequiresLayout
		{
			get { return true; }
		}

	    public TcpAppender(int remotePort, IPAddress remoteAddress)
	    {
	        if (remoteAddress == null) { throw new ArgumentNullException("remoteAddress", "Remote address of the location must be specified."); }
            RemoteAddress = remoteAddress;

            if (remotePort < IPEndPoint.MinPort || remotePort > IPEndPoint.MaxPort) 
			{
				throw SystemInfo.CreateArgumentOutOfRangeException("value", remotePort, 
                    string.Format("The value specified is less than {0} or greater than {1}.",
                    IPEndPoint.MinPort.ToString(NumberFormatInfo.InvariantInfo), IPEndPoint.MaxPort.ToString(NumberFormatInfo.InvariantInfo)));
			}
            RemotePort = remotePort;

            Encoding = Encoding.Default;
	    }

        protected override void OnClose()
        {
            base.OnClose();
            if (Client != null)
            {
                Client.Close();
                Client = null;
            }
        }
	}
}
