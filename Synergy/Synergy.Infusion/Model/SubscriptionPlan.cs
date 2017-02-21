using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Infusion.Model
{
    public class SubscriptionPlan
    {
        [JsonProperty("id")]
        public int Id { get; set; }

        [JsonProperty("subscription_plan_name")]
        public string SubscriptionPlanName { get; set; }

        //The length of each cycle. (6 = Daily, 3 = Weekly, 2 = Month, 1= Yearly)
        [JsonProperty("cycle")]
        public int Cycle { get; set; }

        [JsonProperty("frequency")]
        public int Frequency { get; set; }

        [JsonProperty("number_of_cycles")]
        public int NumberOfCycles { get; set; }

        [JsonProperty("subscription_plan_index")]
        public int SubscriptionPlanIndex { get; set; }

        [JsonProperty("plan_price")]
        public float PlanPrice { get; set; }

        [JsonProperty("active")]
        public bool Active { get; set; }
    }
}
