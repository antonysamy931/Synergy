using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Model
{
    public class DealResponse
    {
        public int portalId { get; set; }
        public int dealId { get; set; }
        public bool isDeleted { get; set; }
        public AssociationsResponse associations { get; set; }
        public DealProperties properties { get; set; }
        public object[] imports { get; set; }
    }
}
