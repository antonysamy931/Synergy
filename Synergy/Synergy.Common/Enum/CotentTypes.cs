using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Common
{
    public enum ContentTypes
    {
        [Description("application/json")]
        JSON,
        [Description("application/x-www-form-urlencoded")]
        URLENCODED
    }
}
