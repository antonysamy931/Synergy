using Newtonsoft.Json;
using Synergy.Common.CustomAttribute;
using Synergy.Common.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.AgileCRM.Model
{

    public class ContactsResponse
    {
        public Contact[] Contacts { get; set; }
    }

    public class Contact
    {
        public long id { get; set; }
        public string type { get; set; }
        public int created_time { get; set; }
        public int updated_time { get; set; }
        public int last_contacted { get; set; }
        public int last_emailed { get; set; }
        public int last_campaign_emaild { get; set; }
        public int last_called { get; set; }
        public int viewed_time { get; set; }
        public Viewed viewed { get; set; }
        public int star_value { get; set; }
        public int lead_score { get; set; }
        public string klout_score { get; set; }
        public string[] tags { get; set; }
        public Tagswithtime[] tagsWithTime { get; set; }
        public Property[] properties { get; set; }
        public object[] campaignStatus { get; set; }
        public string entity_type { get; set; }
        public string source { get; set; }
        public string contact_company_id { get; set; }
        public object[] unsubscribeStatus { get; set; }
        public object[] emailBounceStatus { get; set; }
        public int formId { get; set; }
        public string[] browserId { get; set; }
        public int lead_source_id { get; set; }
        public int lead_status_id { get; set; }
        public bool is_lead_converted { get; set; }
        public int lead_converted_time { get; set; }
        public bool is_duplicate_existed { get; set; }
        public Owner owner { get; set; }
        public string guid { get; set; }
        public Geo_Point geo_point { get; set; }
        public string cursor { get; set; }
    }

    public class Viewed
    {
        public long viewed_time { get; set; }
        public long viewer_id { get; set; }
    }

    public class Owner
    {
        public long id { get; set; }
        public string domain { get; set; }
        public string email { get; set; }
        public string phone { get; set; }
        public string name { get; set; }
        public string pic { get; set; }
        public string schedule_id { get; set; }
        public string calendar_url { get; set; }
        public string calendarURL { get; set; }
    }

    public class Geo_Point
    {
        public float latitude { get; set; }
        public float longitude { get; set; }
    }

    public class Tagswithtime
    {
        public string tag { get; set; }
        public long createdTime { get; set; }
        public int availableCount { get; set; }
        public string entity_type { get; set; }
    }

    public class Property
    {
        public string type { get; set; }
        public string name { get; set; }
        public string value { get; set; }
        public string subtype { get; set; }
    }

    public class UpdateContactRequest : SynergyRequest
    {
        public UpdateContactRequest()
        {
        }

        public UpdateContactRequest(int userId)
            : base(userId: userId, api: ApiTypes.AgileCrm, request: "Update Contact details")
        {
        }

        public long Id { get; set; }
        public ContactProperty Property { get; set; }
    }

    public class CreateContactRequest : SynergyRequest
    {      
        public CreateContactRequest()
        {
        }

        public CreateContactRequest(int userId)
            : base(userId: userId, api: ApiTypes.AgileCrm, request: "Create New Contact")
        {
        }

        public int StarValue { get; set; }     
        public int LeadScore { get; set; }        
        public string[] Tags { get; set; }
        public ContactProperty Property { get; set; }
    }

    public class GetContactRequest : SynergyRequest
    {
        public GetContactRequest()
        {
        }

        public GetContactRequest(int userId)
            : base(userId: userId, api: ApiTypes.AgileCrm, request: "Get Contact by Id")
        {
        }

        public long Id { get; set; }
    }

    public class GetContactByEmailRequest : SynergyRequest
    {
        public GetContactByEmailRequest()
        {
        }

        public GetContactByEmailRequest(int userId)
            : base(userId: userId, api: ApiTypes.AgileCrm, request: "Get Contact by Email")
        {
        }

        public string Email { get; set; }
    }

    public class DeleteContactRequest : SynergyRequest
    {
        public DeleteContactRequest()
        {
        }

        public DeleteContactRequest(int userId)
            : base(userId: userId, api: ApiTypes.AgileCrm, request: "Delete Contact by Id")
        {
        }

        public long Id { get; set; }
    }

    public class GetContactsRequest : SynergyRequest
    {        
        public GetContactsRequest()
        {
        }

        public GetContactsRequest(int userId)
            : base(userId: userId, api: ApiTypes.AgileCrm, request: "Get Contacts")
        {
        }

    }

    public class GetContactsResponse : SynergyResponse
    {
        public List<Contact> Contacts { get; set; }
    }

    public class GetContactResponse : SynergyResponse
    {
        public Contact Contact { get; set; }
    }

    public class AddContactResponse : SynergyResponse
    {
    }

    public class UpdateContactResponse : SynergyResponse
    {
    }

    public class DeleteContactResponse : SynergyResponse
    {
    }

    public class ContactProperty
    {
        [PropertyAttribute(Type = "SYSTEM", Name = "first_name")]
        public string FirstName { get; set; }
        [PropertyAttribute(Type = "SYSTEM", Name = "last_name")]
        public string LastName { get; set; }
        [PropertyAttribute(Type = "SYSTEM", Name = "email", SubType = "work")]
        public string Email { get; set; }
        [PropertyAttribute(Type = "SYSTEM", Name = "address")]
        public Address Address { get; set; }
        [PropertyAttribute(Name = "phone", SubType = "work")]
        public string Phone_Work { get; set; }
        [PropertyAttribute(Name = "phone", SubType = "home")]
        public string Phone_Home { get; set; }
        [PropertyAttribute(Name = "website", SubType = "YOUTUBE")]
        public string YouTube { get; set; }
        [PropertyAttribute(Name = "website", SubType = "LINKEDIN")]
        public string LinkedIn { get; set; }
        [PropertyAttribute(Name = "website", SubType = "URL")]
        public string Url { get; set; }
        [PropertyAttribute(Type = "CUSTOM", Name = "List of companies associated")]
        public string[] Companies { get; set; }
        [PropertyAttribute(Type = "CUSTOM")]
        public Dictionary<string, object> CustomAttribute { get; set; }
    }

    public class Address
    {
        public string address { get; set; }
        public string city { get; set; }
        public string state { get; set; }
        public string zip { get; set; }
        public string country { get; set; }
    }
}
