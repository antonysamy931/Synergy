using Newtonsoft.Json;
using Synergy.Common;
using Synergy.Common.Utilities;
using Synergy.Hubspot.Enum;
using Synergy.Hubspot.Model;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Synergy.Hubspot.Utilities;

namespace Synergy.Hubspot.Api
{
    public class ContactApi : BaseHubspot
    {
        public ContactResponse AddContact(ContactModel model)
        {
            return Add(model);
        }

        public ContactResponse UpdateContact(ContactModel model, string uid)
        {
            return Update(uid, model);
        }

        public ContactsResponse GetContacts()
        {
            return GetContacts(GetUrl(UrlType.Contact, UrlSubType.Contacts));
        }

        public ContactResponse GetContact(long uid)
        {
            return GetContact(string.Format(GetUrl(UrlType.Contact, UrlSubType.ContactById), uid));
        }

        public void DeleteContact(long uid)
        {
            Delete(string.Format(GetUrl(UrlType.Contact, UrlSubType.ContactDeleteById), uid));
        }

        #region Private

        private ContactResponse Add(ContactModel model)
        {
            ContactResponse Contact = new ContactResponse();
            string url = GetUrl(UrlType.Contact, UrlSubType.ContactAdd);
            ContactRequest request = new ContactRequest()
            {
                Properties = model.ToProperties()
            };
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Post(JsonConvert.SerializeObject(request), url, AuthorizationHeader.GetAuthorizationToken(_AccessToken.Accesstoken), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Contact = JsonConvert.DeserializeObject<ContactResponse>(rawResponse);
            }
            return Contact;
        }

        private ContactResponse Update(string uid, ContactModel model)
        {
            ContactResponse Contact = new ContactResponse();
            string url = string.Format(GetUrl(UrlType.Contact, UrlSubType.ContactById), uid);
            ContactRequest request = new ContactRequest()
            {
                Properties = model.ToProperties()
            };
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Post(JsonConvert.SerializeObject(request), url, AuthorizationHeader.GetAuthorizationToken(_AccessToken.Accesstoken), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Contact = JsonConvert.DeserializeObject<ContactResponse>(rawResponse);
            }
            return Contact;
        }

        private ContactsResponse GetContacts(string url)
        {
            ContactsResponse Contacts = new ContactsResponse();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(url, EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON), AuthorizationHeader.GetAuthorizationToken(_AccessToken.Accesstoken));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Contacts = JsonConvert.DeserializeObject<ContactsResponse>(rawResponse);
            }
            return Contacts;
        }

        private ContactResponse GetContact(string url)
        {
            ContactResponse Contact = new ContactResponse();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(url, EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON), AuthorizationHeader.GetAuthorizationToken(_AccessToken.Accesstoken));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Contact = JsonConvert.DeserializeObject<ContactResponse>(rawResponse);
            }
            return Contact;
        }

        private void Delete(string url)
        {            
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Delete(url, EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON), AuthorizationHeader.GetAuthorizationToken(_AccessToken.Accesstoken));
        }

        #endregion
    }
}
