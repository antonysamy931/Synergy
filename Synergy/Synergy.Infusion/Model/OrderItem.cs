using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Infusion.Model
{
    public class OrderItem
    {
        [JsonProperty("id")]
        public int Id { get; set; }

        [JsonProperty("name")]
        public string Name { get; set; }

        [JsonProperty("description")]
        public string Description { get; set; }

        [JsonProperty("type")]
        public string Type { get; set; }

        [JsonProperty("notes")]
        public string Notes { get; set; }

        [JsonProperty("quantity")]
        public int Quantity { get; set; }

        [JsonProperty("cost")]
        public float Cost { get; set; }

        [JsonProperty("price")]
        public float Price { get; set; }

        [JsonProperty("discount")]
        public float? Discount { get; set; }
    }
}
