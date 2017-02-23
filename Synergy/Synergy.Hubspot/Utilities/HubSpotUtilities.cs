using Synergy.Common.Utilities;
using Synergy.Hubspot.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Utilities
{
    public class HubSpotUtilities
    {
        public static List<Property> ClassPropertyToDictionary<T>(object classObject)
        {
            List<Property> Properties = new List<Property>();
            Type ClassType = classObject.GetType();
            foreach (var property in ClassType.GetProperties())
            {
                Property propertyModel = new Property();
                string Name = AttributeUtilities.GetDescription<T>(property);
                propertyModel.PropertyName = string.IsNullOrEmpty(Name) ? property.Name : Name;                
                propertyModel.Value = Convert.ToString(property.GetValue(classObject));
                Properties.Add(propertyModel);
            }
            return Properties;
        }
    }
}
