using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Common.Utilities
{
    public class JsonHelper
    {
        public static string ReplaceNullOrEmpty(object obj, string conversionType)
        {
            var settings = new JsonSerializerSettings() { ContractResolver = new NullOrStringEmptyResolver(conversionType) };
            return JsonConvert.SerializeObject(obj, settings).ToString();
        }

        private class NullOrStringEmptyResolver : DefaultContractResolver
        {
            string conversionType = null;
            public NullOrStringEmptyResolver(string type)
            {
                conversionType = type;
            }

            protected override IList<JsonProperty> CreateProperties(Type type, MemberSerialization memberSerialization)
            {
                return type.GetProperties().Select(p =>
                {
                    var property = base.CreateProperty(p, memberSerialization);
                    property.ValueProvider = new EmptyStringValueProvider(p, conversionType);
                    return property;
                }).ToList();
            }
        }

        public class EmptyStringValueProvider : IValueProvider
        {
            PropertyInfo _PropertyInfo;
            string conversionType = null;

            public EmptyStringValueProvider(PropertyInfo propInfo, string type)
            {
                _PropertyInfo = propInfo;
                conversionType = type;
            }

            public object GetValue(object target)
            {
                object result = _PropertyInfo.GetValue(target);
                if (conversionType == "NullToEmpty")
                {
                    if (_PropertyInfo.PropertyType == typeof(string) && result == null)
                        result = "";
                }
                else
                {
                    if (_PropertyInfo.PropertyType == typeof(string) && (result != null && string.IsNullOrEmpty(result.ToString())))
                        result = null;
                }
                return result;

            }

            public void SetValue(object target, object value)
            {
                _PropertyInfo.SetValue(target, value);
            }
        }
    }
}
