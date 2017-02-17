using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Common.Utilities
{
    public class ConfigurationReader
    {
        public static string GetValue(string key)
        {
            return ConfigurationManager.AppSettings[key];
        }

        public static string GetValue(int index)
        {
            return ConfigurationManager.AppSettings[index];
        }
    }
}
