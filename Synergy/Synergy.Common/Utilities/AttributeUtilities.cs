using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Common.Utilities
{
    public class AttributeUtilities
    {
        public static string GetDescription(PropertyInfo propertyInfo, Type attributeType)
        {
            string Description = string.Empty;
            object Attribute = propertyInfo.GetCustomAttribute(attributeType);
            dynamic DiscriptionAttribute = Attribute;
            if (DiscriptionAttribute != null)
                Description = DiscriptionAttribute.Description;
            return string.IsNullOrEmpty(Description) ? propertyInfo.Name : Description;
        }

        public static string GetDescription<T>(PropertyInfo propertyInfo)
        {
            string Description = string.Empty;
            object Attribute = propertyInfo.GetCustomAttribute(typeof(T));
            dynamic DiscriptionAttribute = (T)Attribute;
            if (DiscriptionAttribute != null)
                Description = DiscriptionAttribute.Description;
            return string.IsNullOrEmpty(Description) ? propertyInfo.Name : Description;
        }
    }
}
