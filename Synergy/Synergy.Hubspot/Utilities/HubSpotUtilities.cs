using Synergy.Common.Utilities;
using Synergy.Hubspot.Model;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Utilities
{
    public static class HubSpotUtilities
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

        public static List<Property> ToProperties(this ContactModel model)
        {
            List<Property> Properties = new List<Property>();
            Type ClassType = model.GetType();
            foreach (var property in ClassType.GetProperties())
            {
                Property propertyModel = new Property();
                string Name = AttributeUtilities.GetDescription<DescriptionAttribute>(property);
                propertyModel.PropertyName = string.IsNullOrEmpty(Name) ? property.Name : Name;
                propertyModel.Value = Convert.ToString(property.GetValue(model));
                Properties.Add(propertyModel);
            }
            return Properties;
        }

        public static List<Property> ToDealProperty(this DealModelProperty model)
        {
            List<Property> Properties = new List<Property>();
            Type ClassType = model.GetType();
            foreach (var property in ClassType.GetProperties())
            {
                Property propertyModel = new Property();
                string Name = AttributeUtilities.GetDescription<DescriptionAttribute>(property);
                propertyModel.PropertyName = string.IsNullOrEmpty(Name) ? property.Name : Name;
                propertyModel.Value = Convert.ToString(property.GetValue(model));
                if (string.IsNullOrEmpty(propertyModel.Value))
                    continue;
                Properties.Add(propertyModel);
            }
            return Properties;
        }

        public static object ToDealRequest(this DealModel model)
        {
            return new
            {
                associations = new {
                    associatedCompanyIds = model.AssociationCompanies,
                    associatedVids = model.AssociationContacts
                },
                properties = model.Property.ToDealProperty()
            };
        }
    }
}
