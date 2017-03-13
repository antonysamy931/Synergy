using Synergy.AgileCRM.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.AgileCRM.Utility
{
    public static class ObjectExtensions
    {

        public static object ConvertToCreateContactRequest(this CreateContactRequest model)
        {
            return new
            {
                star_value = model.LeadScore,
                lead_score = model.StarValue,
                tags = model.Tags,
                properties = model.Property.ConvertToPropertyList()
            };
        }

        public static object ConvertToUpdateContactPropertyRequest(this UpdateContactRequest model)
        {
            return new
            {
                id = model.Id,
                properties = model.Property.ConvertToPropertyList()
            };
        }
    }
}
