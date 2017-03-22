﻿using Synergy.CodeFirst.Filters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Synergy.CodeFirst.Controllers
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
