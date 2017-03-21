using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Model
{
    public class DealModel
    {
        public string[] AssociationCompanies { get; set; }
        public string[] AssociationContacts { get; set; }
        public DealModelProperty Property { get; set; }
    }

    public class DealModelProperty
    {
        [Description("dealname")]
        public string Name { get; set; }
        [Description("dealstage")]
        public string Stage { get; set; }
        [Description("pipeline")]
        public string PipeLine { get; set; }
        [Description("hubspot_owner_id")]
        public int HubspotOwnerId { get; set; }
        [Description("closedate")]
        public string CloseDate { get; set; }
        [Description("amount")]
        public long Amount { get; set; }
        [Description("dealtype")]
        public string DealType { get; set; }
    }
}
