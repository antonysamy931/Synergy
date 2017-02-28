using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Model
{
    public class Version
    {
        [JsonProperty("timestamp")]
        public long TimeStamp { get; set; }
        [JsonProperty("selected")]
        public bool Selected { get; set; }
        [JsonProperty("source-label")]
        public string SourceLabel { get; set; }
        [JsonProperty("value")]
        public string Value { get; set; }
        [JsonProperty("source-type")]
        public string SourceType { get; set; }
        [JsonProperty("source-id")]
        public string SourceId { get; set; }
    }
}
