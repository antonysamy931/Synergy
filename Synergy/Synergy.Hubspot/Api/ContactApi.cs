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

namespace Synergy.Hubspot.Api
{
    public class ContactApi : BaseHubspot
    {
        public ContactResponse AddContact(ContactModel model)
        {
            return new ContactResponse();
        }

        public ContactsResponse GetContacts()
        {
            return GetContacts(GetUrl(UrlType.Contact, UrlSubType.Contacts));
        }

        public ContactResponse GetContact(long uid)
        {
            return GetContact(string.Format(GetUrl(UrlType.Contact, UrlSubType.ContactById), uid));
        }

        #region Private

        private void Add(ContactModel model)
        {
            string url = GetUrl(UrlType.Contact, UrlSubType.ContactAdd);
        }

        private ContactRequest Prepare(ContactModel model)
        {
            Type modelType = model.GetType();
            List<Property> Properties = new List<Property>();
            foreach (var property in modelType.GetProperties())
            {
                Property oProperty = new Property();
                oProperty.PropertyName = AttributeUtilities.GetDescription<DescriptionAttribute>(property);
                oProperty.Value = Convert.ToString(property.GetValue(model));
            }
            return new ContactRequest() { Properties = Properties };
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

        #endregion
    }
}
