using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Model
{
    public class ContactRequest
    {
        [JsonProperty("properties")]
        public List<Property> Properties { get; set; }
    }
}
