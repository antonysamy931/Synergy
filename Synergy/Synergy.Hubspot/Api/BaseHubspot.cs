using Synergy.Common.Model;
using Synergy.Hubspot.Enum;
using Synergy.Hubspot.Utilities;
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

        public string GetUrl(UrlType type, UrlSubType subType)
        {
            string url = string.Empty;
            switch (type)
            {
                case UrlType.Contact:
                    switch (subType)
                    {
                        case UrlSubType.Add:
                            url = string.Format("{0}{1}", RequestUrl.BaseUrl, RequestUrl.CreateContact);
                            break;
                        default:
                            break;
                    }
                    break;
                default:
                    break;
            }
            return url;
        }
    }
}
