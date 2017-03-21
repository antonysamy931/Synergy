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
using Synergy.Hubspot.Utilities;

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

        public DealResponse AddDeal(DealModel request)
        {
            return Add(request);
        }

        public DealResponse UpdateDeal(DealModelProperty request, long uid)
        {
            return Update(request, uid);
        }

        public void RemoveDeal(long uid)
        {
            Delete(string.Format(GetUrl(UrlType.Deal, UrlSubType.DealById), uid));
        }

        #region Private
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

        private DealResponse Add(DealModel model)
        {
            DealResponse Deal = new DealResponse();
            string url = GetUrl(UrlType.Deal, UrlSubType.DealAdd);            
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Post(JsonConvert.SerializeObject(model.ToDealRequest()), url, AuthorizationHeader.GetAuthorizationToken(_AccessToken.Accesstoken), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Deal = JsonConvert.DeserializeObject<DealResponse>(rawResponse);
            }
            return Deal;
        }

        public DealResponse Update(DealModelProperty model, long uid)
        {
            DealResponse Deal = new DealResponse();
            string url = string.Format(GetUrl(UrlType.Deal, UrlSubType.DealById), uid);
            var request = new
            {
                properties = model.ToDealProperty()
            };
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Put(JsonConvert.SerializeObject(request), url, AuthorizationHeader.GetAuthorizationToken(_AccessToken.Accesstoken), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Deal = JsonConvert.DeserializeObject<DealResponse>(rawResponse);
            }
            return Deal;
        }

        private void Delete(string url)
        {
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Delete(url, EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON), AuthorizationHeader.GetAuthorizationToken(_AccessToken.Accesstoken));
        }

        #endregion

    }
}
