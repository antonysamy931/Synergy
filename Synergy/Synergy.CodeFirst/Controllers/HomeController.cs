﻿using Synergy.Admin.New.Filters;
using Synergy.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Synergy.Admin.New.Controllers
{
    public class HomeController : Controller
    {
        //
        // GET: /Home/
        [SynergyAuthorize]
        public ActionResult Index()
        {
            if (SynergySecurity.IsAdmin())
                return RedirectToAction("Index", "Administration");
            return View();
        }

    }
}
