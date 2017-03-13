using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.AgileCRM.Model
{

    public class DealsResponse
    {
        public Deal[] deals { get; set; }
    }

    public class Deal
    {
        public string colorName { get; set; }
        public long id { get; set; }
        public bool apply_discount { get; set; }
        public float discount_value { get; set; }
        public float discount_amt { get; set; }
        public string discount_type { get; set; }
        public string name { get; set; }
        public object[] contact_ids { get; set; }
        public object[] custom_data { get; set; }
        public object[] products { get; set; }
        public string description { get; set; }
        public float expected_value { get; set; }
        public string milestone { get; set; }
        public int probability { get; set; }
        public int close_date { get; set; }
        public int created_time { get; set; }
        public int milestone_changed_time { get; set; }
        public string entity_type { get; set; }
        public object[] notes { get; set; }
        public object[] note_ids { get; set; }
        public int note_created_time { get; set; }
        public long pipeline_id { get; set; }
        public bool archived { get; set; }
        public int won_date { get; set; }
        public int lost_reason_id { get; set; }
        public int deal_source_id { get; set; }
        public float total_deal_value { get; set; }
        public int updated_time { get; set; }
        public bool isCurrencyUpdateRequired { get; set; }
        public float currency_conversion_value { get; set; }
        public object[] tags { get; set; }
        public Tagswithtime[] tagsWithTime { get; set; }
        public Owner owner { get; set; }
        public object[] contacts { get; set; }
    }

    public class DealRequest
    {
        public string name { get; set; }
        public long expected_value { get; set; }
        public int probability { get; set; }
        public long close_date { get; set; }
        public string milestone { get; set; }
        public List<long> contact_ids { get; set; }        
    }

    public class UpdateDealRequest
    {
        public long id { get; set; }
        public string name { get; set; }
        public long expected_value { get; set; }
        public int probability { get; set; }        
        public string milestone { get; set; }
        public List<long> contact_ids { get; set; }       
    }
}
