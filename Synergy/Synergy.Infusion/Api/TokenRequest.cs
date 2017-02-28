using Newtonsoft.Json;
using Synergy.Common;
using Synergy.Common.Model;
using Synergy.Common.Request;
using Synergy.Common.Utilities;
using Synergy.Infusion.Model;
using Synergy.Infusion.Utilities;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Infusion.Api
{
    public class TokenRequest : ReadConfiguration
    {
        public TokenRequest(string Key = "", string Secret = "")
            : base(Key, Secret)
        {
        }

        public AccessToken RequestAccessToken(string code, Uri redirectUri)
        {
            if (_AccessToken != null)
            {
                return _AccessToken;
            }

            if (string.IsNullOrEmpty(code))
                throw new Exception("Required authorization code.");

            if (redirectUri == null)
                throw new Exception("Required redirect uri.");

            if (!UriUtilities.IsHttps(redirectUri))
                throw new Exception("Redirect uri must be secure connection(https).");

            return GetAccessToken(code, redirectUri.ToString());
        }

        public void RefreshAccessToken()
        {
            GetAccessToken(_AccessToken);
        }

        /// <summary>
        /// If already get access token use this method
        /// </summary>
        /// <returns></returns>
        public AccessToken GetAccessToken()
        {
            return _AccessToken;
        }

        private AccessToken GetAccessToken(string code, string redirectUri)
        {
            AccessToken Token = new AccessToken();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            var Content = string.Format("client_id={0}&client_secret={1}&code={2}&grant_type={3}&redirect_uri={4}", InfusionKey, InfusionSecret, code, GrantType, redirectUri);
            HttpWebResponse response = client.Post(new JsonMessage(Encoding.UTF8.GetBytes(Content), GetAccessTokenUrl()), null, EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.URLENCODED));
            if (response != null && response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Token = JsonConvert.DeserializeObject<AccessToken>(rawResponse);
                _AccessToken = Token;
            }
            return Token;
        }

        private AccessToken GetAccessToken(AccessToken token)
        {
            AccessToken Token = new AccessToken();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();            
            HttpWebResponse response = client.Post(new JsonMessage(null, GetRefreshTokenUrl(token.RefreshToken)), GetAuthenticationToken(), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON));
            if (response != null && response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                Token = JsonConvert.DeserializeObject<AccessToken>(rawResponse);
                _AccessToken = Token;
            }
            return Token;
        }

        private string GetAccessTokenUrl()
        {
            return string.Format("{0}", RequestUrl.AccessToken);
        }

        private string GetRefreshTokenUrl(string refreshToken)
        {
            return string.Format("{0}?grant_type={1}&refresh_token={2}", RequestUrl.AccessToken, RefreshGrantType, refreshToken);
        }
    }
}
