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
using Synergy.Common.Model;

namespace Synergy.AgileCRM.Api
{
    public class ContactApi : ReadConfiguration
    {
        public ContactApi(string agileKey = "", string agileEmail = "", string agileUrl = "")
            : base(agileKey, agileEmail, agileUrl)
        {

        }

        public AddContactResponse AddContact(CreateContactRequest model)
        {
            return Create(model);
        }

        public GetContactsResponse GetContacts(GetContactsRequest request)
        {
            return GetContacts(AgileCRMConstant.Contacts);
        }

        public GetContactResponse GetContact(GetContactRequest request)
        {
            return GetContact(AgileCRMConstant.Contacts + "/" + request.Id);
        }

        public DeleteContactResponse DeleteContact(DeleteContactRequest request)
        {
            return Delete(AgileCRMConstant.Contacts + "/" + request.Id);
        }

        public UpdateContactResponse UpdateContactProperty(UpdateContactRequest model)
        {
            return Update(AgileCRMConstant.UpdateContactProperties, model);
        }

        #region Private methods

        private GetContactsResponse GetContacts(string url)
        {
            GetContactsResponse contactsResponse = new GetContactsResponse();           
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(GetUrl(url), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON), GetAuthorization());
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                var Contacts = JsonConvert.DeserializeObject<List<Contact>>(rawResponse);
                contactsResponse.Contacts = Contacts;
                contactsResponse.Status = Status.Success;
            }
            else
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                contactsResponse.Status = Status.Error;
                contactsResponse.Message = rawResponse;
            }
            return contactsResponse;
        }

        private GetContactResponse GetContact(string url)
        {
            GetContactResponse contactResponse = new GetContactResponse();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(GetUrl(url), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON), GetAuthorization());
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                var Contact = JsonConvert.DeserializeObject<Contact>(rawResponse);
                contactResponse.Contact = Contact;
                contactResponse.Status = Status.Success;
            }
            else
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                contactResponse.Status = Status.Error;
                contactResponse.Message = rawResponse;
            }
            return contactResponse;
        }

        private AddContactResponse Create(CreateContactRequest model)
        {
            AddContactResponse synergyResponse = new AddContactResponse();
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
                synergyResponse.Status = Status.Success;
            }
            else
            {
                synergyResponse.Status = Status.Error;
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                synergyResponse.Message = rawResponse;
            }
            return synergyResponse;
        }

        private DeleteContactResponse Delete(string url)
        {
            DeleteContactResponse deleteResponse = new DeleteContactResponse();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Delete(GetUrl(url), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON), GetAuthorization());
            if (response.StatusCode == HttpStatusCode.OK)
            {
                deleteResponse.Status = Status.Success;
            }
            else
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                deleteResponse.Message = rawResponse;
                deleteResponse.Status = Status.Error;
            }
            return deleteResponse;
        }

        private UpdateContactResponse Update(string url, UpdateContactRequest model)
        {
            UpdateContactResponse updateResponse = new UpdateContactResponse();
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
                updateResponse.Status = Status.Success;                
            }
            else
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                updateResponse.Message = rawResponse;
                updateResponse.Status = Status.Error;
            }
            return updateResponse;
        }

        #endregion
    }
}
