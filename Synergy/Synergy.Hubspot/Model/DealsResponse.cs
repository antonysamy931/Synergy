using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Model
{
    public class DealsResponse
    {
        public DealResponse[] deals { get; set; }
        public bool hasMore { get; set; }
        public int offset { get; set; }
    }
}
