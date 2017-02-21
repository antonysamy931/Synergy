using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Infusion.Model
{
    public class BaseResponse
    {
        [JsonProperty("count")]
        public int Count { get; set; }

        [JsonProperty("next")]
        public int? Next { get; set; }

        [JsonProperty("previous")]
        public int? Previous { get; set; }

        [JsonProperty("sync_token")]
        public string SyncToken { get; set; }
    }
}
