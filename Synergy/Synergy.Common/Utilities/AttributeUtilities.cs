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

        public static string GetTypeValue(PropertyInfo propertyInfo, Type attributeType)
        {
            string TypeValue = string.Empty;
            object Attribute = propertyInfo.GetCustomAttribute(attributeType);
            dynamic CustomAttribute = Attribute;
            if (CustomAttribute != null)
                TypeValue = CustomAttribute.Type;
            return TypeValue;
        }

        public static string GetSubTypeValue(PropertyInfo propertyInfo, Type attributeType)
        {
            string SubTypeValue = string.Empty;
            object Attribute = propertyInfo.GetCustomAttribute(attributeType);
            dynamic CustomAttribute = Attribute;
            if (CustomAttribute != null)
                SubTypeValue = CustomAttribute.SubType;
            return SubTypeValue;
        }

        public static string GetName(PropertyInfo propertyInfo, Type attributeType)
        {
            string NameValue = string.Empty;
            object Attribute = propertyInfo.GetCustomAttribute(attributeType);
            dynamic CustomAttribute = Attribute;
            if (CustomAttribute != null)
                NameValue = CustomAttribute.Name;
            return NameValue;
        }
    }
}
