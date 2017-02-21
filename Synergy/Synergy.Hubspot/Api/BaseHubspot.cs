using Synergy.Common.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Api
{
    public abstract class BaseHubspot
    {
        public static AccessToken _AccessToken { get; set; }
    }
}
