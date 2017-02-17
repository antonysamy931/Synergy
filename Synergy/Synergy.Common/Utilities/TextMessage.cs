using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Formatting;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Common.Utilities
{
    public class TextMessage : IContentType
    {
        public TextMessage(byte[] message, string url)
        {
            this.Url = url;
            this.Content = message;
        }

        public MediaTypeFormatter MediaTypeFormatter
        {
            get
            {
                return new TextMediaTypeFormatter();
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
                return "text/plain";
            }

        }

    }
}
