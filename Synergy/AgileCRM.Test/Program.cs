using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace AgileCRM.Test
{
    class Program
    {
        static void Main(string[] args)
        {
            /***************************************************************/
            string result = string.Empty;
            const string url = "https://antonysamy.agilecrm.com/dev/api/contacts";
            String encoded = System.Convert.ToBase64String(System.Text.Encoding.ASCII.GetBytes("antonysamy931@gmail.com:kesfef51bnhrdqaud0l3siecbv"));            
            HttpWebRequest request = WebRequest.Create(url) as HttpWebRequest;
            
            request.Method = "GET";
            request.ContentType = "application/json";
            request.Accept = "application/json";

            request.Headers.Add("Authorization", "Basic " + encoded);
            using (HttpWebResponse response = request.GetResponse() as HttpWebResponse)
            {
                Stream dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream);
                result = reader.ReadToEnd();

                reader.Close();
                dataStream.Close();
                response.Close();
            }
        }
    }
}
