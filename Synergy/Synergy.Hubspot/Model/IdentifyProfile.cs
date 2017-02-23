using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Model
{
    public class IdentifyProfile
    {
        [JsonProperty("identifies")]
        public List<Identify> Identifies { get; set; }
        [JsonProperty("vid")]
        public long Vid { get; set; }
    }
}
