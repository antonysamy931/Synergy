using Newtonsoft.Json;
using Synergy.Common;
using Synergy.Common.Utilities;
using Synergy.Hubspot.Enum;
using Synergy.Hubspot.Model;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Api
{
    public class DealApi : BaseHubspot
    {
        public DealsResponse GetDeals()
        {
            return GetDeals(GetUrl(UrlType.Deal, UrlSubType.Deals));
        }

        public DealResponse GetById(long uid)
        {
            return GetDeal(string.Format(GetUrl(UrlType.Deal, UrlSubType.DealById), uid));
        }

        private DealsResponse GetDeals(string url)
        {
            DealsResponse Deals = new DealsResponse();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(url, EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON), AuthorizationHeader.GetAuthorizationToken(_AccessToken.Accesstoken));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Deals = JsonConvert.DeserializeObject<DealsResponse>(rawResponse);
            }
            return Deals;
        }

        private DealResponse GetDeal(string url)
        {
            DealResponse Deal = new DealResponse();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(url, EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON), AuthorizationHeader.GetAuthorizationToken(_AccessToken.Accesstoken));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Deal = JsonConvert.DeserializeObject<DealResponse>(rawResponse);
            }
            return Deal;
        }
    }
}
