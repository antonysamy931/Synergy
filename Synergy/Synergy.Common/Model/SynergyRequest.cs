
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Common.Model
{
    public class SynergyRequest
    {
        public int UserId { get; set; }

        public ApiTypes Api { get; set; }

        public string Request { get; set; }
    }
}
