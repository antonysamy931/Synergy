using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Infusion.Model
{
    public class Product
    {
        [JsonProperty("id")]
        public int Id { get; set; }

        [JsonProperty("product_name")]
        public string ProductName { get; set; }

        [JsonProperty("product_desc")]
        public string ProductDesc { get; set; }

        [JsonProperty("product_short_desc")]
        public string ProductShortDesc { get; set; }

        [JsonProperty("product_price")]
        public float ProductPrice { get; set; }

        [JsonProperty("sku")]
        public string SKU { get; set; }

        [JsonProperty("sub_category_id")]
        public string SubCategoryId { get; set; }

        //Whether the product is active 1 or inactive 0
        [JsonProperty("status")]
        public int Status { get; set; }

        //If the product should be sold only as a subscription and not a one-time product
        [JsonProperty("subscription_only")]
        public bool SubscriptionOnly { get; set; }

        [JsonProperty("url")]
        public string Url { get; set; }

        [JsonProperty("product_options")]
        public List<ProductOption> ProductOptions { get; set; }

        [JsonProperty("subscription_plans")]
        public List<SubscriptionPlan> SubscriptionPlans { get; set; }
    }
}
