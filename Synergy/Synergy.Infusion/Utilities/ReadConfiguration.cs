using Synergy.Infusion.Api;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Infusion.Utilities
{
    public abstract class ReadConfiguration : BaseInfusion
    {
        private const string Key = "Infusion.Key";
        private const string Secret = "Infusion.Secret";
        
        public const string ResponseType = "code";
        public const string GrantType = "authorization_code";
        public const string RefreshGrantType = "refresh_token";

        private static string _InfusionKey;
        private static string _InfusionSecret;

        public ReadConfiguration(string Key, string Secret)
        {
            if (!string.IsNullOrEmpty(Key) && !string.IsNullOrEmpty(Secret))
            {
                _InfusionKey = Key;
                _InfusionSecret = Secret;
            }
        }

        public string InfusionKey
        {
            get
            {
                if (string.IsNullOrEmpty(_InfusionKey))
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
                    return _InfusionKey;
                }
            }

            private set
            {
                value = _InfusionKey;
            }
        }

        public string InfusionSecret
        {
            get
            {
                if (string.IsNullOrEmpty(_InfusionSecret))
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
                    return _InfusionSecret;
                }
            }

            private set
            {
                value = _InfusionSecret;
            }
        }

        public string GetAuthenticationToken()
        {
            string token = InfusionKey + ":" + InfusionSecret;
            return "Basic " + Convert.ToBase64String(Encoding.UTF8.GetBytes(token));
        }

    }
}
