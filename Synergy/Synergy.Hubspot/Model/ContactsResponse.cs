using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Model
{
    public class ContactsResponse
    {
        [JsonProperty("contacts")]
        public List<ContactResponse> Contacts { get; set; }
        [JsonProperty("hasmore")]
        public bool HasMore { get; set; }
        [JsonProperty("vidoffset")]
        public int VidOffSet { get; set; }
    }
}
