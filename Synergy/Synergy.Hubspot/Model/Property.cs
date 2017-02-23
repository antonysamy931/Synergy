using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Model
{
    public class Property
    {
        [JsonProperty("property")]
        public string PropertyName { get; set; }
        [JsonProperty("value")]
        public string Value { get; set; }
    }
}
