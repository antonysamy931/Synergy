using Synergy.Admin.Filters;
using Synergy.Admin.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Synergy.Security;

namespace Synergy.Admin.Controllers
{
    [SynergyAuthorize(Role = "User")]
    public class AgileCRMController : Controller
    {

        public ActionResult Index()
        {
            return View();
        }

        public ActionResult Configurations()
        {
            List<AgileCrmModel> model = null;
            using (var ctx = new SynergyDbContext())
            {
                string ApiName = ApiTypes.HubSpot.ToString();
                var api = ctx.Synergy_API.Where(x => x.Api == ApiName).FirstOrDefault();

                model = ctx.Synergy_ApiConfigurations.                    
                    Where(x => x.IsActive && x.ApiId == api.Id).
                    Select(x => new AgileCrmModel()
                    {
                        Id = x.Id,
                        Key = x.Key,
                        Url = x.Url,
                        Email = x.Email
                    }).ToList();
            }
            return View(model);
        }

        [HttpGet]
        public ActionResult Register()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Register(AgileCrmModel model)
        {
            ModelState.Remove("Id");
            if (ModelState.IsValid)
            {
                using (var ctx = new SynergyDbContext())
                {
                    string ApiName = ApiTypes.AgileCrm.ToString();
                    var api = ctx.Synergy_API.Where(x => x.Api == ApiName).FirstOrDefault();
                    Synergy_ApiConfiguration configuration = new Synergy_ApiConfiguration()
                    {
                        ApiId = api.Id,
                        Email = model.Email,
                        Key = model.Key,
                        Url = model.Url,
                        UserId = Convert.ToInt32(User.Identity.Name),
                        IsActive = true
                    };
                    ctx.Synergy_ApiConfigurations.Add(configuration);
                    ctx.SaveChanges();
                }
                return RedirectToAction("Index");
            }
            return View(model);
        }

        [HttpGet]
        public ActionResult Update(int id)
        {
            AgileCrmModel model = null;
            using (var ctx = new SynergyDbContext())
            {
                model = ctx.Synergy_ApiConfigurations.
                    Where(x => x.Id == id && x.IsActive).
                    Select(x => new AgileCrmModel()
                {
                    Id = x.Id,
                    Key = x.Key,
                    Url = x.Url,
                    Email = x.Email
                }).FirstOrDefault();
            }
            return View(model);
        }

        [HttpPost]
        public ActionResult Update(AgileCrmModel model)
        {
            if (ModelState.IsValid)
            {
                using (var ctx = new SynergyDbContext())
                {
                    var configuration = ctx.Synergy_ApiConfigurations.
                    Where(x => x.Id == model.Id && x.IsActive).FirstOrDefault();
                    if (configuration != null)
                    {
                        configuration.Key = model.Key;
                        configuration.Email = model.Email;
                        configuration.Url = model.Url;
                    }
                    ctx.SaveChanges();
                }
                return RedirectToAction("Index");
            }
            return View(model);
        }

        [HttpGet]
        public ActionResult Detail(int id)
        {
            AgileCrmModel model = null;
            using (var ctx = new SynergyDbContext())
            {
                model = ctx.Synergy_ApiConfigurations.
                    Where(x => x.Id == id && x.IsActive).
                    Select(x => new AgileCrmModel()
                    {
                        Id = x.Id,
                        Key = x.Key,
                        Url = x.Url,
                        Email = x.Email
                    }).FirstOrDefault();
            }
            return View(model);
        }

        [HttpGet]
        public ActionResult Delete(int id)
        {
            AgileCrmModel model = null;
            using (var ctx = new SynergyDbContext())
            {
                model = ctx.Synergy_ApiConfigurations.
                    Where(x => x.Id == id && x.IsActive).
                    Select(x => new AgileCrmModel()
                    {
                        Id = x.Id,
                        Key = x.Key,
                        Url = x.Url,
                        Email = x.Email
                    }).FirstOrDefault();
            }
            return View(model);
        }

        [HttpPost]
        public ActionResult Delete(int id, FormCollection collection)
        {
            using (var ctx = new SynergyDbContext())
            {
                var configuration = ctx.Synergy_ApiConfigurations.
                Where(x => x.Id == id && x.IsActive).FirstOrDefault();
                if (configuration != null)
                {
                    configuration.IsActive = false;
                }
                ctx.SaveChanges();
            }
            return RedirectToAction("Index");
        }
    }
}
