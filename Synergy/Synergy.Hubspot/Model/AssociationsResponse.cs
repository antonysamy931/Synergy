using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Model
{
    public class AssociationsResponse
    {
        public int?[] associatedVids { get; set; }
        public int?[] associatedCompanyIds { get; set; }
        public object[] associatedDealIds { get; set; }
    }
}
