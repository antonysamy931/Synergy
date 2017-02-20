using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Infusion.Utilities
{
    public abstract class ReadConfiguration
    {
        private const string Key = "Infusion.Key";
        private const string Secret = "Infusion.Secret";
        
        public const string ResponseType = "code";
        public const string GrantType = "authorization_code";
        public const string RefreshGrantType = "refresh_token";

        public string InfusionKey
        {
            get
            {
                try
                {
                    return ConfigurationManager.AppSettings[Key].ToString();
                }
                catch(Exception ex)
                {
                    throw new Exception(string.Format("'{0}' key not found.", Key));
                }
            }
        }

        public string InfusionSecret
        {
            get
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
        }

        public string GetAuthenticationToken()
        {
            string token = InfusionKey + ":" + InfusionSecret;
            return "Basic " + Convert.ToBase64String(Encoding.UTF8.GetBytes(token));
        }

    }
}
