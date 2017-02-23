using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Model
{
    public class ResponseProperty
    {
        [JsonProperty("value")]
        public string Value { get; set; }
        [JsonProperty("versions")]
        public List<Version> Versions { get; set; }
    }
}
