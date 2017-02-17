using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Infusion.Utilities
{
    public static class RequestUrl
    {
        public const string InfusionBaseUrl = "https://api.infusionsoft.com/crm/rest/v1/";

        public const string Authorization = "https://signin.infusionsoft.com/app/oauth/authorize";

        public const string AccessToken = "https://api.infusionsoft.com/token";
    }
}
