using Newtonsoft.Json;
using Synergy.AgileCRM.Model;
using Synergy.Common.CustomAttribute;
using Synergy.Common.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.AgileCRM.Utility
{
    public static class ConvertProperty
    {
        private static List<string> DataTypes = new List<string>() { "String", "Boolean", "Int32", "Int64", "Single", "Double" };

        public static dynamic ConvertToPropertyList(this ContactProperty model, bool create = false)
        {
            List<dynamic> properties = new List<dynamic>();
            Type type = model.GetType();
            foreach (var property in type.GetProperties())
            {
                Dictionary<string, string> prop = new Dictionary<string, string>();
                string propType, propName, propSubType, propValue = string.Empty;
                bool typeExist = false;
                bool subTypeExist = false;

                //Assign values
                if (DataTypes.Any(x => x.ToLower() == property.PropertyType.Name.ToLower()))
                    propValue = Convert.ToString(property.GetValue(model));
                else
                    propValue = JsonConvert.SerializeObject(property.GetValue(model),
                        new JsonSerializerSettings()
                        {
                            NullValueHandling = NullValueHandling.Ignore,
                            DefaultValueHandling = DefaultValueHandling.Ignore,
                            Converters = new List<Newtonsoft.Json.JsonConverter> {
                            new Newtonsoft.Json.Converters.StringEnumConverter()
                        }
                        });

                if (propValue == "null" || string.IsNullOrEmpty(propValue))
                    continue;
                else
                    prop.Add("value", propValue);

                propType = AttributeUtilities.GetTypeValue(property, typeof(PropertyAttribute));
                propName = AttributeUtilities.GetName(property, typeof(PropertyAttribute));
                propSubType = AttributeUtilities.GetSubTypeValue(property, typeof(PropertyAttribute));

                if (!string.IsNullOrEmpty(propType))
                {
                    prop.Add("type", propType);
                    typeExist = true;
                }

                if (!string.IsNullOrEmpty(propName))
                    prop.Add("name", propName);

                if (!string.IsNullOrEmpty(propSubType) && !create)
                {
                    prop.Add("subtype", "propSubType");
                    subTypeExist = true;
                }

                if (typeExist && subTypeExist)
                {
                    properties.Add(new { 
                        type = prop["type"],
                        name = prop["name"],
                        value = prop["value"],
                        subtype = prop["subtype"]
                    });
                }
                else if (typeExist)
                {
                    properties.Add(new
                    {
                        type = prop["type"],
                        name = prop["name"],
                        value = prop["value"]                        
                    });
                }
                else if (subTypeExist)
                {
                    properties.Add(new
                    {                        
                        name = prop["name"],
                        value = prop["value"],
                        subtype = prop["subtype"]
                    });
                }               
            }
            return properties;
        }
    }
}
