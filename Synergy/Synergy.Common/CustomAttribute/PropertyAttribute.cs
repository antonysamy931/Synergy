using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Common.CustomAttribute
{
    public class PropertyAttribute : Attribute
    {
        public string Type;
        public string Name;
        public string SubType;

        public PropertyAttribute()
        {
        }

        public PropertyAttribute(string type)
        {
            Type = type;
        }

        public PropertyAttribute(string type, string name)
        {
            Type = type;
            Name = name;         
        }

        public PropertyAttribute(string type, string name, string subType)
        {
            Type = type;
            Name = name;
            SubType = subType;
        }
    }
}
