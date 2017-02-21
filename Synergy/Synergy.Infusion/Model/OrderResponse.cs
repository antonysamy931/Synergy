using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Infusion.Model
{
    public class OrderResponse : BaseResponse
    {
        [JsonProperty("orders")]
        public List<Order> Orders { get; set; }
    }
}
