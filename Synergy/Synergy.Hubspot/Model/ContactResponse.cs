using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Model
{
    public class ContactResponse
    {
        [JsonProperty("identity-profiles")]
        public List<IdentifyProfile> IdentifyProfiles { get; set; }
        [JsonProperty("properties")]
        public ContactProperties Properties { get; set; }
        [JsonProperty("vid")]
        public int Vid { get; set; }
        [JsonProperty("addedAt")]
        public long AddedAt { get; set; }
        [JsonProperty("canonicalvid")]
        public int Canonicalvid { get; set; }
        [JsonProperty("mergedvids")]
        public object[] MergedVids { get; set; }
        [JsonProperty("portalid")]
        public int PortalId { get; set; }
        [JsonProperty("iscontact")]
        public bool IsContact { get; set; }
        [JsonProperty("profiletoken")]
        public string ProfileToken { get; set; }
        [JsonProperty("profileurl")]
        public string ProfileUrl { get; set; }
        [JsonProperty("formsubmissions")]
        public object[] FormSubmissions { get; set; }
        [JsonProperty("mergeaudits")]
        public object[] MergeAudits { get; set; }
        [JsonProperty("associatedcompany")]
        public ContactAssociatedCompany AssociatedCompany { get; set; }
    }

    public class ContactAssociatedCompany
    {        
        public int companyid { get; set; }
        public int portalid { get; set; }
        public ContactProperties properties { get; set; }
    }
}
