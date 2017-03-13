using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.AgileCRM.Api
{
    public abstract class ReadConfiguration
    {
        private static string _AgileKey;
        private static string _AgileUrl;
        private static string _AgileEmail;

        private const string Key = "agile.key";
        private const string Email = "agile.email";
        private const string BaseUrl = "agile.url";

        public ReadConfiguration(string agileKey, string agileEmail, string agileUrl)
        {
            if (!string.IsNullOrEmpty(agileKey))
                _AgileKey = agileKey;
            if (!string.IsNullOrEmpty(agileUrl))
                _AgileUrl = agileUrl;
            if (!string.IsNullOrEmpty(agileEmail))
                _AgileEmail = agileEmail;
        }

        public string AgileKey
        {
            get
            {
                if (string.IsNullOrEmpty(_AgileKey))
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
                    return _AgileKey;
                }
            }

            private set
            {
                value = _AgileKey;
            }
        }

        public string AgileUrl
        {
            get
            {
                if (string.IsNullOrEmpty(_AgileUrl))
                {
                    try
                    {
                        return ConfigurationManager.AppSettings[BaseUrl].ToString();
                    }
                    catch (Exception ex)
                    {
                        throw new Exception(string.Format("'{0}' key not found.", BaseUrl));
                    }
                }
                else
                {
                    return _AgileUrl;
                }
            }

            private set
            {
                value = _AgileUrl;
            }
        }

        public string AgileEmail
        {
            get
            {
                if (string.IsNullOrEmpty(_AgileEmail))
                {
                    try
                    {
                        return ConfigurationManager.AppSettings[Email].ToString();
                    }
                    catch (Exception ex)
                    {
                        throw new Exception(string.Format("'{0}' key not found.", Email));
                    }
                }
                else
                {
                    return _AgileEmail;
                }
            }

            private set
            {
                value = _AgileEmail;
            }
        }

        protected string GetUrl(string request)
        {
            if (AgileUrl.Substring(AgileUrl.Length - 1).Equals("/"))
                return string.Format("{0}dev/api/{1}", AgileUrl, request);
            else
                return string.Format("{0}/dev/api/{1}", AgileUrl, request);
        }

        protected string GetAuthorization()
        {
            String encoded = System.Convert.ToBase64String(System.Text.Encoding.ASCII.GetBytes(AgileEmail + ":" + AgileKey));
            return "Basic " + encoded;
        }

        protected string GetJson(object model)
        {
            return JsonConvert.SerializeObject(
                        model,
                        new JsonSerializerSettings()
                        {
                            NullValueHandling = NullValueHandling.Ignore,
                            DefaultValueHandling = DefaultValueHandling.Ignore,
                            Converters = new List<Newtonsoft.Json.JsonConverter> {
                            new Newtonsoft.Json.Converters.StringEnumConverter()
                        }
                        });
        }        

        public byte[] GetBytes(object model)
        {
            return System.Text.Encoding.UTF8.GetBytes(GetJson(model));
        }
    }
}
