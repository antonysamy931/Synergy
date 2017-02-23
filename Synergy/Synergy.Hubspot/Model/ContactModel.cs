using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Model
{
    public class ContactModel
    {
        [Description("email")]
        public string Email { get; set; }
        [Description("firstname")]
        public string FristName { get; set; }
        [Description("lastname")]
        public string LastName { get; set; }
        [Description("website")]
        public string Website { get; set; }
        [Description("company")]
        public string Company { get; set; }
        [Description("phone")]
        public string Phone { get; set; }
        [Description("address")]
        public string Address { get; set; }
        [Description("city")]
        public string City { get; set; }
        [Description("state")]
        public string State { get; set; }
        [Description("zip")]
        public string ZipCode { get; set; }
    }
}
