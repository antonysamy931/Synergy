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

        public List<Deal> GetDeals()
        {
            return GetDeals("opportunity");
        }

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
    }
}
