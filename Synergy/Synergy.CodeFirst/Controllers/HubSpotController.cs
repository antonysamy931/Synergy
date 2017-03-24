﻿using Synergy.Admin.New.Filters;
using Synergy.Admin.New.Models;
using Synergy.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Synergy.Admin.New.Controllers
{
    [SynergyAuthorize(Role = "User")]
    public class HubSpotController : Controller
    {
        SynergyDbContext context = null;
        public HubSpotController()
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
            List<HubSpotModel> model = context.Synergy_ApiConfigurations.
                Where(x => x.IsActive && x.ApiId == api.Id).
                Select(x => new HubSpotModel()
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

        public ActionResult Register(HubSpotModel model)
        {
            ModelState.Remove("Id");
            if (ModelState.IsValid)
            {
                string ApiName = ApiTypes.HubSpot.ToString();
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
            HubSpotModel model = context.Synergy_ApiConfigurations.
                Where(x => x.Id == id && x.IsActive).
                Select(x => new HubSpotModel()
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
            HubSpotModel model = context.Synergy_ApiConfigurations.
               Where(x => x.Id == id && x.IsActive).
               Select(x => new HubSpotModel()
               {
                   Id = x.Id,
                   Key = x.Key,
                   Secret = x.Secret
               }).FirstOrDefault();
            return View(model);
        }

        [HttpPost]
        public ActionResult Update(HubSpotModel model)
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
            HubSpotModel model = context.Synergy_ApiConfigurations.
               Where(x => x.Id == id && x.IsActive).
               Select(x => new HubSpotModel()
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
