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
    public class OrderApi : BaseInfusion
    {
        public OrderResponse GetOrders()
        {
            OrderResponse orderResponse = new OrderResponse();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(GetUrl("orders"), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                orderResponse = JsonConvert.DeserializeObject<OrderResponse>(rawResponse);
            }
            return orderResponse;
        }

        public Order GetOrder(int id)
        {
            Order order = new Order();
            Synergy.Common.Request.WebClient client = new Synergy.Common.Request.WebClient();
            HttpWebResponse response = client.Get(GetUrl("orders/" + id), EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON));
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var responseStream = response.GetResponseStream();
                StreamReader streamReader = new StreamReader(responseStream);
                string rawResponse = streamReader.ReadToEnd();
                order = JsonConvert.DeserializeObject<Order>(rawResponse);
            }
            return order;
        }
    }
}
