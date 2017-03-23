using Synergy.CodeFirst.Filters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Synergy.CodeFirst.Controllers
{
    [SynergyAuthorize]
    public class HubSpotController : Controller
    {
        //
        // GET: /HubSpot/

        public ActionResult Index()
        {
            return View();
        }

    }
}
