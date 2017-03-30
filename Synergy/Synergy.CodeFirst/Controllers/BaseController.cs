using Synergy.AgileCRM.Api;
using Synergy.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Synergy.Admin.New.Controllers
{
    public class BaseController : Controller
    {        
        public void AgileCrmInit(ref ContactApi contactApi, ref DealApi dealApi)
        {
            using (var ctx = new SynergyDbContext())
            {
                var userId = SynergySecurity.GetCurrentUser();

                var apiConfiguration = ctx.Synergy_ApiConfigurations.
                    Where(x => x.UserId == userId && x.IsActive).FirstOrDefault();
                if (apiConfiguration != null)
                {
                    contactApi = new ContactApi(agileKey: apiConfiguration.Key, agileEmail: apiConfiguration.Email, agileUrl: apiConfiguration.Url);
                    dealApi = new DealApi(agileKey: apiConfiguration.Key, agileEmail: apiConfiguration.Email, agileUrl: apiConfiguration.Url);
                }
                else
                {
                    contactApi = new ContactApi();
                    dealApi = new DealApi();
                }
            }
        }
    }
}
