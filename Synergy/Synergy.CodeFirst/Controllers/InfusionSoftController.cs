using Synergy.Admin.Filters;
using Synergy.Admin.Models;
using Synergy.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Synergy.Admin.Controllers
{
    [SynergyAuthorize(Role = "User")]
    public class InfusionSoftController : Controller
    {
        SynergyDbContext context = null;
        public InfusionSoftController()
        {
            context = new SynergyDbContext();
        }

        public ActionResult Index()
        {
            return View();
        }

        public ActionResult Configuration()
        {
            string ApiName = ApiTypes.HubSpot.ToString();
            var api = context.Synergy_API.Where(x => x.Api == ApiName).FirstOrDefault();

            List<InfusionSoftModel> model = context.Synergy_ApiConfigurations.
                Where(x => x.IsActive && x.ApiId == api.Id).
                Select(x => new InfusionSoftModel()
                {
                    Id = x.Id,
                    Key = x.Key,
                    Secret = x.Secret
                }).ToList();
            return View(model);
        }

        [HttpGet]
        public ActionResult Register()
        {
            return View();
        }

        public ActionResult Register(InfusionSoftModel model)
        {
            ModelState.Remove("Id");
            if (ModelState.IsValid)
            {
                string ApiName = ApiTypes.Infusion.ToString();
                var api = context.Synergy_API.Where(x => x.Api == ApiName).FirstOrDefault();

                Synergy_ApiConfiguration configuration = new Synergy_ApiConfiguration()
                {
                    Key = model.Key,
                    Secret = model.Secret,
                    ApiId = api.Id,
                    UserId = Convert.ToInt32(User.Identity.Name),
                    IsActive = true
                };
                context.Synergy_ApiConfigurations.Add(configuration);
                context.SaveChanges();
                return RedirectToAction("Index");
            }
            return View(model);
        }

        public ActionResult Detail(int id)
        {
            InfusionSoftModel model = context.Synergy_ApiConfigurations.
                Where(x => x.Id == id && x.IsActive).
                Select(x => new InfusionSoftModel()
                {
                    Id = x.Id,
                    Key = x.Key,
                    Secret = x.Secret
                }).FirstOrDefault();
            return View(model);
        }

        [HttpGet]
        public ActionResult Update(int id)
        {
            InfusionSoftModel model = context.Synergy_ApiConfigurations.
               Where(x => x.Id == id && x.IsActive).
               Select(x => new InfusionSoftModel()
               {
                   Id = x.Id,
                   Key = x.Key,
                   Secret = x.Secret
               }).FirstOrDefault();
            return View(model);
        }

        [HttpPost]
        public ActionResult Update(InfusionSoftModel model)
        {
            if (ModelState.IsValid)
            {
                var configuration = context.Synergy_ApiConfigurations.
                Where(x => x.Id == model.Id && x.IsActive).FirstOrDefault();
                if (configuration != null)
                {
                    configuration.Key = model.Key;
                    configuration.Secret = model.Secret;
                }
                context.SaveChanges();

                return RedirectToAction("Index");
            }
            return View(model);
        }

        [HttpGet]
        public ActionResult Delete(int id)
        {
            InfusionSoftModel model = context.Synergy_ApiConfigurations.
               Where(x => x.Id == id && x.IsActive).
               Select(x => new InfusionSoftModel()
               {
                   Id = x.Id,
                   Key = x.Key,
                   Secret = x.Secret
               }).FirstOrDefault();
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
