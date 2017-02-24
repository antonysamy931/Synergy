using Synergy.Hubspot.Api;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Utilities
{
    public abstract class ReadConfiguration : BaseHubspot
    {
        private const string Key = "Hubspot.Key";
        private const string Secret = "Hubspot.Secret";

        public const string ResponseType = "code";
        public const string GrantType = "authorization_code";
        public const string RefreshGrantType = "refresh_token";

        private static string _HubKey;
        private static string _HubSecret;
        
        public ReadConfiguration(string hubKey, string hubSecret)
        {
            if (!string.IsNullOrEmpty(hubKey) && !string.IsNullOrEmpty(hubSecret))
            {
                _HubKey = hubKey;
                _HubSecret = hubSecret;
            }
        }
        
        public string HubspotClientID
        {
            get
            {
                if (string.IsNullOrEmpty(_HubKey))
                {
                    try
                    {
                        return ConfigurationManager.AppSettings[Key].ToString();
                    }
                    catch (Exception ex)
                    {
                        throw new Exception(string.Format("'{0}' key not found.", Key));
                    }
                }
                else
                {
                    return _HubKey;
                }
            }

            private set
            {
                value = _HubKey;
            }
        }

        public string HubspotSecret
        {
            get
            {
                if (string.IsNullOrEmpty(_HubSecret))
                {
                    try
                    {
                        return ConfigurationManager.AppSettings[Secret].ToString();
                    }
                    catch (Exception ex)
                    {
                        throw new Exception(string.Format("'{0}' key not found.", Secret));
                    }
                }
                else
                {
                    return _HubSecret;
                }
            }

            private set
            {
                value = _HubSecret;
            }
        }

        public string GetAuthenticationToken()
        {
            string token = HubspotClientID + ":" + HubspotSecret;
            return "Basic " + Convert.ToBase64String(Encoding.UTF8.GetBytes(token));
        }

    }
}
