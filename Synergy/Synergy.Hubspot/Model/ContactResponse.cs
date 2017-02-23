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
    }
}
