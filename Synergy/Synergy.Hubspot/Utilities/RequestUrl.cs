﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Utilities
{
    public static class RequestUrl
    {
        public const string Authorize = "https://app.hubspot.com/oauth/authorize";
        public const string BaseUrl = "https://api.hubapi.com/";
        public const string AccessToken = "https://api.hubapi.com/oauth/v1/token";
        public const string AccessTokenInfo = "https://api.hubapi.com/oauth/v1/access-tokens/";
        public const string RefreshTokenInfo = "https://api.hubapi.com/oauth/v1/refresh-tokens/";
    }
}
