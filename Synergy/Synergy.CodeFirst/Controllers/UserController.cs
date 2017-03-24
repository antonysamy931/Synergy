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
    [SynergyAuthorize(Role = "Admin")]
    public class UserController : Controller
    {
        //
        // GET: /User/
        private SynergyDbContext _context = new SynergyDbContext();

        public ActionResult Index()
        {
            var users = _context.Synergy_Users.Where(x => x.UserRole != "admin" && x.IsActive).Select(x => new UserModel()
            {
                Age = x.Age,
                Email = x.Email,
                FirstName = x.FirstName,
                Id = x.UserId,
                LastName = x.LastName,
                UserName = _context.Synergy_Accounts.Where(y => y.UserId == x.UserId && x.IsActive).Select(y => y.UserName).FirstOrDefault()
            }).ToList();
            return View(users);
        }

        //
        // GET: /User/Details/5

        public ActionResult Details(int id)
        {
            var user = _context.Synergy_Users.Where(x => x.UserId == id && x.IsActive).Select(x => new UserModel()
            {
                Age = x.Age,
                Email = x.Email,
                FirstName = x.FirstName,
                Id = x.UserId,
                LastName = x.LastName,
                UserName = _context.Synergy_Accounts.Where(y => y.UserId == x.UserId && x.IsActive).Select(y => y.UserName).FirstOrDefault()
            }).FirstOrDefault();
            return View(user);
        }

        //
        // GET: /User/Create

        public ActionResult Create()
        {
            return View();
        }

        //
        // POST: /User/Create

        [HttpPost]
        public ActionResult Create(UserModel model)
        {
            ModelState.Remove("Id");
            if (ModelState.IsValid)
            {
                Synergy_User user = new Synergy_User()
                {
                    Age = model.Age,
                    Email = model.Email,
                    FirstName = model.FirstName,
                    LastName = model.LastName,
                    IsActive = true,
                    UserRole = "user",
                };
                SynergySecurity.Create(user, model.UserName);
                return RedirectToAction("Index");
            }
            return View(model);
        }

        //
        // GET: /User/Edit/5

        public ActionResult Edit(int id)
        {
            var user = _context.Synergy_Users.Where(x => x.UserId == id && x.IsActive).Select(x => new UserModel()
            {
                Age = x.Age,
                Email = x.Email,
                FirstName = x.FirstName,
                Id = x.UserId,
                LastName = x.LastName,
                UserName = _context.Synergy_Accounts.Where(y => y.UserId == x.UserId && x.IsActive).Select(y => y.UserName).FirstOrDefault()
            }).FirstOrDefault();
            return View(user);
        }

        //
        // POST: /User/Edit/5

        [HttpPost]
        public ActionResult Edit(int id, UserModel model)
        {
            ModelState.Remove("Id");
            if (ModelState.IsValid)
            {
                SynergySecurity.Update(id, model.Age, model.Email, model.FirstName, model.LastName);
                return RedirectToAction("Index");
            }
            return View(model);
        }

        //
        // GET: /User/Delete/5

        public ActionResult Delete(int id)
        {
            var user = _context.Synergy_Users.Where(x => x.UserId == id && x.IsActive).Select(x => new UserModel()
            {
                Age = x.Age,
                Email = x.Email,
                FirstName = x.FirstName,
                Id = x.UserId,
                LastName = x.LastName,
                UserName = _context.Synergy_Accounts.Where(y => y.UserId == x.UserId && x.IsActive).Select(y => y.UserName).FirstOrDefault()
            }).FirstOrDefault();
            return View(user);
        }

        //
        // POST: /User/Delete/5

        [HttpPost]
        public ActionResult Delete(int id, FormCollection collection)
        {
            SynergySecurity.Delete(id);
            return RedirectToAction("Index");
        }
    }
}
