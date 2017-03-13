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
using Synergy.AgileCRM.Utility;

namespace Synergy.AgileCRM.Api
{
    public class ContactApi : ReadConfiguration
    {
        public ContactApi(string agileKey = "", string agileEmail = "", string agileUrl = "")
            : base(agileKey, agileEmail, agileUrl)
        {

        }

        public void AddContact(CreateContactRequest model)
        {
            Create(model);
        }

        public List<Contact> GetContacts()
        {
            return GetContacts(AgileCRMConstant.Contacts);
        }

        public Contact GetContact(long id)
        {
            return GetContact(AgileCRMConstant.Contacts + "/" + id);
        }

        public void DeleteContact(long id)
        {
            Delete(AgileCRMConstant.Contacts + "/" + id);
        }

        public void UpdateContactProperty(UpdateContactRequest model)
        {
            Update(AgileCRMConstant.UpdateContactProperties, model);
        }

        #region Private methods

        private List<Contact> GetContacts(string url)
        {
            List<Contact> Contacts = new List<Contact>();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(GetUrl(url), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON), GetAuthorization());
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Contacts = JsonConvert.DeserializeObject<List<Contact>>(rawResponse);
            }
            return Contacts;
        }

        private Contact GetContact(string url)
        {
            Contact Contact = new Contact();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(GetUrl(url), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON), GetAuthorization());
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Contact = JsonConvert.DeserializeObject<Contact>(rawResponse);
            }
            return Contact;
        }

        private void Create(CreateContactRequest model)
        {
            Synergy.Common.Request.WebClient client = new Common.Request.WebClient();
            var requestModel = model.ConvertToCreateContactRequest();
            string requestData = GetJson(requestModel);
            HttpWebResponse response = client.Post(JsonConvert.SerializeObject(requestModel), GetUrl(AgileCRMConstant.Contacts), GetAuthorization(), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                var Contact = JsonConvert.DeserializeObject<Contact>(rawResponse);
            }
        }

        private void Delete(string url)
        {
            Contact Contact = new Contact();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Delete(GetUrl(url), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON), GetAuthorization());
        }

        private void Update(string url, UpdateContactRequest model)
        {
            Synergy.Common.Request.WebClient client = new Common.Request.WebClient();
            var requestModel = model.ConvertToUpdateContactPropertyRequest();
            string requestData = GetJson(requestModel);
            HttpWebResponse response = client.Put(JsonConvert.SerializeObject(requestModel), GetUrl(url), GetAuthorization(), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                var Contact = JsonConvert.DeserializeObject<Contact>(rawResponse);
            }
        }

        #endregion
    }
}
