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
                        case UrlSubType.ContactAdd:
                            url = string.Format("{0}{1}", RequestUrl.BaseUrl, RequestUrl.CreateContact);
                            break;
                        case UrlSubType.Contacts:
                            url = string.Format("{0}{1}", RequestUrl.BaseUrl, RequestUrl.GetAllContact);
                            break;
                        case UrlSubType.ContactById:
                            url = (RequestUrl.BaseUrl + RequestUrl.GetContactById);
                            break;
                        case UrlSubType.ContactDeleteById:
                            url = (RequestUrl.BaseUrl + RequestUrl.DeleteContact);
                            break;
                        default:
                            break;
                    }
                    break;
                case UrlType.Deal:
                    switch (subType)
                    {
                        case UrlSubType.Deals:
                            url = string.Format("{0}{1}", RequestUrl.BaseUrl, RequestUrl.GetAllDeals);
                            break;
                        case UrlSubType.DealById:
                            url = (RequestUrl.BaseUrl + RequestUrl.GetDealById);
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
