using Newtonsoft.Json;
using Synergy.Common;
using Synergy.Common.Utilities;
using Synergy.Infusion.Model;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Infusion.Api
{
    public class ProductApi : BaseInfusion
    {
        public ProductResponse GetProducts(ProductRequest request)
        {
            return GetProductsSearch("products/search?limit=" + request.Limit + "&offset=" + request.Offset + "&active=" + request.Active);
        }

        public ProductResponse GetProducts()
        {
            return GetProductsSearch("products/search");
        }

        public Product GetProduct(int id)
        {
            Product product = new Product();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(GetUrl("products/" + id), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                product = JsonConvert.DeserializeObject<Product>(rawResponse);
            }
            return product;
        }

        public ProductResponse GetProductsSearch(string url)
        {
            ProductResponse productResponse = new ProductResponse();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(GetUrl(url), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                productResponse = JsonConvert.DeserializeObject<ProductResponse>(rawResponse);
            }
            return productResponse;
        }
    }
}
