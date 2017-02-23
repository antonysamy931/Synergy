using Synergy.Common.Utilities;
using Synergy.Hubspot.Enum;
using Synergy.Hubspot.Model;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Api
{
    public class ContactApi : BaseHubspot
    {
        public ContactResponse AddContact(ContactModel model)
        {
            return new ContactResponse();
        }

        #region Private
        private void Add(ContactModel model)
        {
            string url = GetUrl(UrlType.Contact, UrlSubType.Add);
        }

        private ContactRequest Prepare(ContactModel model)
        {
            Type modelType = model.GetType();
            List<Property> Properties = new List<Property>();
            foreach (var property in modelType.GetProperties())
            {
                Property oProperty = new Property();
                oProperty.PropertyName = AttributeUtilities.GetDescription<DescriptionAttribute>(property);
                oProperty.Value = Convert.ToString(property.GetValue(model));
            }
            return new ContactRequest() { Properties = Properties };
        }
        #endregion
    }
}
