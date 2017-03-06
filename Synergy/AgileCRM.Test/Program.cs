using Synergy.AgileCRM.Api;
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
            ContactApi api = new ContactApi("a1kb49qb3b3cos9dnmde38n43l", "aaron@synergyframeworks.com", "https://synergyframeworks.agilecrm.com/");
            var result = api.GetContacts();
            DealApi dealApi = new DealApi();
            var s = dealApi.GetDeals();
            /***************************************************************/
            //string result = string.Empty;
            //const string url = "https://antonysamy.agilecrm.com/dev/api/opportunity";
            //String encoded = System.Convert.ToBase64String(System.Text.Encoding.ASCII.GetBytes("antonysamy931@gmail.com:kesfef51bnhrdqaud0l3siecbv"));
            //HttpWebRequest request = WebRequest.Create(url) as HttpWebRequest;

            //request.Method = "GET";
            //request.ContentType = "application/json";
            //request.Accept = "application/json";

            //request.Headers.Add("Authorization", "Basic " + encoded);
            //using (HttpWebResponse response = request.GetResponse() as HttpWebResponse)
            //{
            //    Stream dataStream = response.GetResponseStream();
            //    StreamReader reader = new StreamReader(dataStream);
            //    result = reader.ReadToEnd();

            //    reader.Close();
            //    dataStream.Close();
            //    response.Close();
            //}
        }
    }
}
