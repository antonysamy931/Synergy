using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Common.Utilities
{
    public class UriUtilities
    {        
        public static bool IsHttps(Uri url)
        {
            return url.Scheme.ToLower() == "https";
        }
    }
}
