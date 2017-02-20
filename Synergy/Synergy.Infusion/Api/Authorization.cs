using Synergy.Common.Utilities;
using Synergy.Infusion.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Infusion.Api
{
    public class Authorization : ReadConfiguration
    {
        public Uri GetAuthorizationUrl(Uri redirectUri, string[] scopes)
        {
            string Scopes = string.Empty;

            if (scopes != null && scopes.Length != 0)
                Scopes = string.Join(",", scopes);
            else
                Scopes = "full";

            if (redirectUri == null)
                throw new Exception("Required redirect uri.");

            if (!UriUtilities.IsHttps(redirectUri))
                throw new Exception("Redirect uri must be secure connection(https).");

            return new Uri(GetAuthorizationUrl(redirectUri.ToString(), Scopes));
        }

        private string GetAuthorizationUrl(string redirectUri, string scopes)
        {
            return string.Format("{0}?client_id={1}&redirect_uri={2}&response_type={3}&scope={4}", RequestUrl.Authorization, InfusionKey, redirectUri.ToString(), ResponseType, scopes);
        }
    }
}
