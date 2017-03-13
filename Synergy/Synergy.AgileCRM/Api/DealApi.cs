using Newtonsoft.Json;
using Synergy.AgileCRM.Model;
using Synergy.Common;
using Synergy.Common.Utilities;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.AgileCRM.Api
{
    public class DealApi : ReadConfiguration
    {
        public DealApi(string agileKey = "", string agileEmail = "", string agileUrl = "")
            : base(agileKey, agileEmail, agileUrl)
        {

        }
        #region Public method
        public List<Deal> GetDeals()
        {
            return GetDeals("opportunity");
        }

        public Deal GetDeal(long id)
        {
            return GetDeal("opportunity" + "/" + id);
        }

        public Deal AddDeal(DealRequest model)
        {
            return Create(model);
        }

        public Deal UpdateDeal(UpdateDealRequest model)
        {
            return Update(model);
        }

        public void DeleteDeal(long id)
        {
            Delete("opportunity" + "/" + id);
        }

        #endregion
        #region Private method
        private List<Deal> GetDeals(string url)
        {
            List<Deal> Deals = new List<Deal>();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(GetUrl(url), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON), GetAuthorization());
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Deals = JsonConvert.DeserializeObject<List<Deal>>(rawResponse);
            }
            return Deals;
        }

        private Deal GetDeal(string url)
        {
            Deal Deal = new Deal();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(GetUrl(url), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON), GetAuthorization());
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Deal = JsonConvert.DeserializeObject<Deal>(rawResponse);
            }
            return Deal;
        }

        private Deal Create(DealRequest model)
        {
            Deal Deal = new Deal();
            Synergy.Common.Request.WebClient client = new Common.Request.WebClient();            
            string requestData = GetJson(model);
            HttpWebResponse response = client.Post(requestData, GetUrl("opportunity"), GetAuthorization(), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Deal = JsonConvert.DeserializeObject<Deal>(rawResponse);
            }
            return Deal;
        }

        private Deal Update(UpdateDealRequest model)
        {
            Deal Deal = new Deal();
            Synergy.Common.Request.WebClient client = new Common.Request.WebClient();
            string requestData = GetJson(model);
            HttpWebResponse response = client.Put(requestData, GetUrl("opportunity/partial-update"), GetAuthorization(), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Deal = JsonConvert.DeserializeObject<Deal>(rawResponse);
            }
            return Deal;
        }

        private void Delete(string url)
        {
            Synergy.Common.Request.WebClient client = new Common.Request.WebClient();
            HttpWebResponse response = client.Delete(GetUrl(url), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON), GetAuthorization());                 
        }
        #endregion
    }
}
