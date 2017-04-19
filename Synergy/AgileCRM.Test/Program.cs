using Newtonsoft.Json;
using Synergy.AgileCRM.Api;
using Synergy.AgileCRM.Model;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Synergy.AgileCRM.Utility;
using Synergy.Common.Utilities;
using CookComputing.XmlRpc;
using Microsoft.CSharp;
using System.CodeDom.Compiler;
using System.CodeDom;
using System.Reflection.Emit;
using System.Reflection;
using System.ComponentModel;

namespace AgileCRM.Test
{
    class Program
    {
        static void Main(string[] args)
        {
            #region test
            //string key = "a1kb49qb3b3cos9dnmde38n43l";
            //string email = "aaron@synergyframeworks.com";
            //string url = "https://synergyframeworks.agilecrm.com/";

            //Contact model = new Contact()
            //{
            //    lead_score = 44,
            //    tags = new string[] { "1", "2" },
            //    properties = new Property[]{
            //        new Property(){
            //            type = "SYSTEM",
            //            name = "email",
            //            value = "jason123@gmail.com"
            //        },
            //        new Property(){
            //            type="SYSTEM",
            //            name="first_name",
            //            value="Test First"
            //        },
            //        new Property(){
            //            type="SYSTEM",
            //            name="last_name",
            //            value="Test Last"
            //        }
            //    }
            //};                        

            //CreateContactRequest createrequest = new CreateContactRequest()
            //{
            //    Property = new ContactProperty()
            //    {
            //        FirstName = "green"                    
            //    }
            //};

            //UpdateContactRequest request = new UpdateContactRequest()
            //{
            //    Id = 5692462144159744,
            //    Property = new ContactProperty()
            //    {
            //        FirstName = "Kavan"
            //    }
            //};

            //var model = request.ConvertToUpdateContactPropertyRequest();

            //var json = JsonHelper.ReplaceNullOrEmpty(model, "NullToEmpty");

            //var obj = request.ConvertToCreateContactRequest();

            //var st = JsonConvert.SerializeObject(obj,
            //            new JsonSerializerSettings()
            //            {
            //                NullValueHandling = NullValueHandling.Ignore,
            //                DefaultValueHandling = DefaultValueHandling.Ignore,
            //                Converters = new List<Newtonsoft.Json.JsonConverter> {
            //                new Newtonsoft.Json.Converters.StringEnumConverter()
            //            }
            //            });

            //ContactApi api = new ContactApi("kesfef51bnhrdqaud0l3siecbv", "antonysamy931@gmail.com", "https://antonysamy.agilecrm.com/");

            //api.UpdateContactProperty(request);

            //var contact = api.GetContact(5741031244955648);
            //api.AddContact(createrequest);
            //api.DeleteContact(5757715179634688);

            //var result = api.GetContacts();
            //DealApi dealApi = new DealApi();
            //var s = dealApi.GetDeals();

            /***************************************************************/
            string result = string.Empty;
            //const string url = "https://antonysamy.agilecrm.com/dev/api/opportunity";
            String encoded = System.Convert.ToBase64String(System.Text.Encoding.ASCII.GetBytes("antonysamy931@gmail.com:kesfef51bnhrdqaud0l3siecbv"));
            //HttpWebRequest request = WebRequest.Create("https://antonysamy.agilecrm.com/dev/api/contacts/search/email/test@black.com") as HttpWebRequest;
            HttpWebRequest request = WebRequest.Create("https://antonysamy.agilecrm.com/dev/api/contacts/search?q=jack&page_size=10&type='PERSON'") as HttpWebRequest;
            //string data = "{\"properties\":[{\"type\":\"CUSTOM\",\"name\":\"Test\",\"value\":\"Test custom feed\"}]}";//JsonConvert.SerializeObject(model); //"{\"lead_score\":44,  \"tags\":[\"tag1\", \"tag2\"], \"properties\":[{\"type\":\"SYSTEM\", \"name\":\"email\",\"value\":\"jason123@gmail.com\"}, {\"type\":\"SYSTEM\", \"name\":\"first_name\", \"value\":\"First_name\"}, {\"type\":\"SYSTEM\", \"name\":\"last_name\", \"value\":\"Last_name\"}]}";
            //if (!string.IsNullOrEmpty(data))
            //    request.ContentLength = data.Length;
            request.Method = "GET";
            request.ContentType = "application/json";
            request.Accept = "application/json";

            request.Headers.Add("Authorization", "Basic " + encoded);

            //using (Stream webStream = request.GetRequestStream())
            //using (StreamWriter requestWriter = new StreamWriter(webStream, System.Text.Encoding.ASCII))
            //{
            //    requestWriter.Write(data);
            //}

            using (HttpWebResponse response = request.GetResponse() as HttpWebResponse)
            {
                Stream dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream);
                result = reader.ReadToEnd();
                //var Contact = JsonConvert.DeserializeObject<Contact>(result);
                reader.Close();
                dataStream.Close();
                response.Close();
            }

            //DealApi dealapi = new DealApi("kesfef51bnhrdqaud0l3siecbv", "antonysamy931@gmail.com", "https://antonysamy.agilecrm.com/");
            //DealRequest request = new DealRequest()
            //{
            //    name = "Deal-Tomato",
            //    expected_value = 500,
            //    probability = 75,
            //    close_date = 1455042600,
            //    milestone = "Proposal",
            //    contact_ids = new List<long>(){
            //        5694691248963584
            //    },
            //};

            //dealapi.AddDeal(request);

            //var dealList = dealapi.GetDeals();

            //var deal = dealapi.GetDeal(5675267779461120);

            //UpdateDealRequest request = new UpdateDealRequest()
            //{
            //    id = 5651124426113024,
            //    name = "Test",
            //    expected_value = 700,
            //    probability = 100,
            //    milestone = "New",
            //    contact_ids = new List<long>(){
            //        5694691248963584
            //    },
            //};

            //var deal = dealapi.UpdateDeal(request);

            //dealapi.DeleteDeal(5651124426113024);
            #endregion



            //string Key = "486a702729e365e137ac988ad054fbb8";
            //iFace proxy = XmlRpcProxyGen.Create<iFace>();

            //XmlRpcStruct conDat = new XmlRpcStruct();
            //conDat.Add("FirstName", "Test J");
            //conDat.Add("LastName", "Test K");
            //conDat.Add("Email", "Test@g.com");

            ////make the call to add the contact.
            //try
            //{
            //    var result = proxy.Add(Key, conDat);

            //}
            //catch (Exception ex)
            //{
            //}

            //Type t = typeof(iFace);
            //object Attribute = t.GetCustomAttribute(typeof(XmlRpcUrlAttribute));
            //dynamic uriAttribute = (XmlRpcUrlAttribute)Attribute;

            //var attr = t.GetCustomAttribute(typeof(XmlRpcUrlAttribute));
            ////attr.GetType().GetProperty("Uri").SetValue(attr, "test");
            ////var constructor = attr.GetType().GetConstructor(new[] { typeof(XmlRpcUrlAttribute) });
            ////var attr2 = t.GetCustomAttribute(typeof(XmlRpcUrlAttribute));

            //var constructor = typeof(XmlRpcUrlAttribute).GetConstructor(new[] { typeof(XmlRpcUrlAttribute) });

            //var obj = new A()
            //{
            //    H = new B()
            //    {
            //        T = false
            //    }
            //};

            //foreach (var prop in obj.GetType().GetProperties())
            //{
            //    var type = prop.GetType();
            //    var h = prop.GetValue(obj, null);
            //    foreach (var item in type.GetProperties())
            //    {
            //        var l = item.GetValue(h, null);
            //    }
            //}
        }
    }
    [XmlRpcUrl("https://yu358.infusionsoft.com:443/api/xmlrpc")]
    public interface iFace : IXmlRpcProxy
    {
        [XmlRpcMethod("ContactService.add")]
        int Add(string key, XmlRpcStruct map);

        [XmlRpcMethod("ContactService.addToGroup")]
        bool AddGrp(string key, int conID, int grpID);

        [XmlRpcMethod("ContactService.addToCampaign")]
        bool AddCamp(string key, int conID, int campID);
    }

    public class A
    {
        public B H { get; set; }
    }

    public class B
    {
        public bool T { get; set; }
    }
}
