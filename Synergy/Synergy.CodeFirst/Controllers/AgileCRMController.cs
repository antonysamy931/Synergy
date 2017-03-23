using Synergy.CodeFirst.Filters;
using Synergy.CodeFirst.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Synergy.CodeFirst.Controllers
{
    [SynergyAuthorize]
    public class AgileCRMController : Controller
    {
        //
        // GET: /AgileCRM/

        public ActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public ActionResult Register()
        {
            return View();
        }

        public ActionResult Register(AgileCrmModel model)
        {
            if (ModelState.IsValid)
            {

            }
            return View(model);
        }
    }
}
