using Synergy.Admin.Filters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Synergy.Admin.Controllers
{
    [SynergyAuthorize(Role = "Admin")]
    public class AdministrationController : Controller
    {
        //
        // GET: /Administration/

        public ActionResult Index()
        {
            return View();
        }

    }
}
