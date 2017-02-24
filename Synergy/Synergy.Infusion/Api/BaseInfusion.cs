using Synergy.Common.Model;
using Synergy.Common.Utilities;
using Synergy.Infusion.Model;
using Synergy.Infusion.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Infusion.Api
{
    public abstract class BaseInfusion
    {
        public static AccessToken _AccessToken { get; set; }

        public string GetUrl(string request)
        {
            if (request.Contains('?'))
                return string.Format("{0}{1}&access_token={2}", RequestUrl.InfusionBaseUrl, request, GetAccessToken());
            else
                return string.Format("{0}{1}?access_token={2}", RequestUrl.InfusionBaseUrl, request, GetAccessToken());

        }

        public string GetAccessToken()
        {            
            return _AccessToken.Accesstoken;
        }
    }
}
