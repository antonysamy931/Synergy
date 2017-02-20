using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Formatting;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Common.Utilities
{
    public class JsonMessage : IContentType
    {
        public JsonMessage(byte[] message, string url)
        {
            this.Content = message;
            this.Url = url;
        }

        public MediaTypeFormatter MediaTypeFormatter
        {
            get 
            { 
                return new JsonMediaTypeFormatter(); 
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
                return "application/json";
            }
        }
    }
}
