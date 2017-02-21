using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Infusion.Model
{
    public class ProductRequest
    {
        //Limits the results to at most the given value
        public int Limit { get; set; }

        //The index to where the results should begin
        public int Offset { get; set; }

        //Searches for producs which are marked as active
        public bool Active { get; set; }
    }
}
