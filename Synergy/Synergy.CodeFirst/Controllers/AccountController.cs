using Synergy.CodeFirst.Models;
using Synergy.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Synergy.CodeFirst.Controllers
{
    public class AccountController : Controller
    {
        //
        // GET: /Account/
        [AllowAnonymous]
        public ActionResult Login()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Login(LoginModel model)
        {
            if (ModelState.IsValid)
            {
                if (SynergySecurity.Login(model.UserName, model.Password))
                    return RedirectToAction("Index", "Home");                    
            }
            ModelState.AddModelError("", "Username or Password provide incorrect");
            return View(model);
        }

        public ActionResult Logoff()
        {
            SynergySecurity.Logoff();
            return RedirectToAction("Index", "Home");
        }
    }
}
