using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Infusion.Model
{
    public class Order
    {
        [JsonProperty("id")]
        public int Id { get; set; }

        [JsonProperty("title")]
        public string Title { get; set; }

        [JsonProperty("status")]
        public string Status { get; set; }

        [JsonProperty("recurring")]
        public bool? Recurring { get; set; }

        [JsonProperty("total")]
        public float Total { get; set; }

        [JsonProperty("contact")]
        public Contact Contact { get; set; }

        [JsonProperty("creation_date")]
        public DateTime CreationDate { get; set; }

        [JsonProperty("modification_date")]
        public DateTime ModificationDate { get; set; }

        [JsonProperty("lead_affiliate_id")]
        public int LeadAffiliateId { get; set; }

        [JsonProperty("sales_affiliate_id")]
        public int SalesAffiliateId { get; set; }

        [JsonProperty("total_paid")]
        public float TotalPaid { get; set; }

        [JsonProperty("total_due")]
        public float TotalDue { get; set; }

        [JsonProperty("order_items")]
        public List<OrderItem> OrderItems { get; set; }
    }
}
