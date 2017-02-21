using Newtonsoft.Json;
using Synergy.Common;
using Synergy.Common.Model;
using Synergy.Common.Utilities;
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
    public class TokenRequest : ReadConfiguration
    {        
        private static string RedirectUri { get; set; }

        public AccessToken RequestAccessToken(string code, Uri redirectUri)
        {
            RedirectUri = redirectUri.ToString();

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

        public AccessToken GetAccessToken()
        {            
            return _AccessToken;
        }

        private AccessToken GetAccessToken(string code, string redirectUri)
        {
            AccessToken Token = new AccessToken();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Post(new JsonMessage(null, GetAccessTokenUrl(code, redirectUri)), null, EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.URLENCODED));
            var responseStream = response.GetResponseStream();
            StreamReader streamReader = new StreamReader(responseStream);
            string rawResponse = streamReader.ReadToEnd();
            Token = JsonConvert.DeserializeObject<AccessToken>(rawResponse);
            _AccessToken = Token;
            return Token;
        }

        private AccessToken GetAccessToken(AccessToken token)
        {
            AccessToken Token = new AccessToken();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Post(new JsonMessage(null, GetRefreshTokenUrl(token.RefreshToken)), null, EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.URLENCODED));
            var responseStream = response.GetResponseStream();
            StreamReader streamReader = new StreamReader(responseStream);
            string rawResponse = streamReader.ReadToEnd();
            Token = JsonConvert.DeserializeObject<AccessToken>(rawResponse);
            _AccessToken = Token;

            return Token;
        }

        private string GetAccessTokenUrl(string code, string redirectUri)
        {
            return string.Format("{0}?grant_type={1}&client_id={2}&client_secret={3}&redirect_uri={4}&code={5}", RequestUrl.AccessToken, GrantType, HubspotClientID, HubspotSecret, redirectUri, code);
        }

        private string GetRefreshTokenUrl(string refreshToken)
        {
            return string.Format("{0}?grant_type={1}&client_id={2}&client_secret={3}&redirect_uri={4}&refresh_token={5}", RequestUrl.AccessToken, RefreshGrantType, HubspotClientID, HubspotSecret, RedirectUri, refreshToken);
        }
    }
}
