using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Infusion.Model
{
    public class ProductResponse : BaseResponse
    {
        [JsonProperty("products")]
        public List<Product> Products { get; set; }        
    }
}
