using Newtonsoft.Json;
using Synergy.Common;
using Synergy.Common.Model;
using Synergy.Common.Utilities;
using Synergy.Hubspot.Model;
using Synergy.Hubspot.Utilities;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Api
{
    public class TokenInformationApi : BaseHubspot
    {
        public TokenInfo GetAccessTokenInfo()
        {            
            TokenInfo info = new TokenInfo();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(string.Format("{0}{1}", RequestUrl.AccessTokenInfo, _AccessToken.Accesstoken), 
                EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                info = JsonConvert.DeserializeObject<TokenInfo>(rawResponse);
            }
            return info;
        }

        public TokenInfo GetRequestTokenInfo()
        {
            TokenInfo info = new TokenInfo();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(string.Format("{0}{1}", RequestUrl.RefreshTokenInfo, _AccessToken.RefreshToken),
                EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                info = JsonConvert.DeserializeObject<TokenInfo>(rawResponse);
            }
            return info;
        }
    }
}
