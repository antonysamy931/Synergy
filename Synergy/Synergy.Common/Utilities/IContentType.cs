using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Formatting;
using System.Text;

namespace Synergy.Common.Utilities
{
    public interface IContentType
    {
        MediaTypeFormatter MediaTypeFormatter { get; }

        byte[] Content { get; }

        string Url { get; set; }

        string Header { get; }
    }

    public class XmlMessage : IContentType
    {
        public XmlMessage(byte[] message, string url)
        {
            this.Url = url;
            this.Content = message;
        }

        public MediaTypeFormatter MediaTypeFormatter
        {
            get
            {
                return new XmlMediaTypeFormatter();
            }

        }


        public byte[] Content
        {
            get;
            private set;
        }

        public string Url
        {
            get;
            set;
        }


        public string Header
        {
            get
            {
                return "text/xml";
            }

        }

    }
}
