using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Model
{
    public class ContactProperties
    {
        [JsonProperty("website")]
        public ResponseProperty Website { get; set; }
        [JsonProperty("city")]
        public ResponseProperty City { get; set; }
        [JsonProperty("firstname")]
        public ResponseProperty FirstName { get; set; }
        [JsonProperty("zip")]
        public ResponseProperty ZipCode { get; set; }
        [JsonProperty("lastname")]
        public ResponseProperty LastName { get; set; }
        [JsonProperty("company")]
        public ResponseProperty Company { get; set; }
        [JsonProperty("phone")]
        public ResponseProperty Phone { get; set; }
        [JsonProperty("state")]
        public ResponseProperty State { get; set; }
        [JsonProperty("address")]
        public ResponseProperty Address { get; set; }
        [JsonProperty("email")]
        public ResponseProperty Email { get; set; }
    }
}
