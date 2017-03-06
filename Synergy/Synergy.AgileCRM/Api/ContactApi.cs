using Newtonsoft.Json;
using Synergy.AgileCRM.Model;
using Synergy.Common;
using Synergy.Common.Utilities;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.AgileCRM.Api
{
    public class ContactApi : ReadConfiguration
    {
        public ContactApi(string agileKey = "", string agileEmail = "", string agileUrl = "")
            : base(agileKey, agileEmail, agileUrl)
        {

        }

        public List<Contact> GetContacts()
        {
            return GetContacts("contacts");
        }

        public List<Contact> GetContacts(string url)
        {
            List<Contact> Contacts = new List<Contact>();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(GetUrl(url), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON),GetAuthorization());
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Contacts = JsonConvert.DeserializeObject < List<Contact>>(rawResponse);
            }
            return Contacts;
        }
    }
}
