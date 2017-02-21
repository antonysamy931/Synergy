using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Common.Utilities
{
    public class AuthorizationHeader
    {
        public static string GetAuthorizationToken(string accessToken)
        {
            return "Bearer " + accessToken;
        }
    }
}
