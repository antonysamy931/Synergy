using Synergy.Admin.New.Filters;
using Synergy.Admin.New.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Synergy.Security;
using Synergy.AgileCRM.Api;
using Synergy.AgileCRM.Model;
using Newtonsoft.Json;

namespace Synergy.Admin.New.Controllers
{
    [SynergyAuthorize(Role = "User")]
    public class AgileCRMController : BaseController
    {
        #region Property
        ContactApi contactApi = null;
        DealApi dealApi = null;
        #endregion

        #region Constructor

        public AgileCRMController()
        {
            AgileCrmInit(ref contactApi, ref dealApi);
        }

        #endregion

        #region Register
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
        #endregion

        #region Contact
        public ActionResult Contacts()
        {
            var request = new GetContactsRequest();
            request.UserId = SynergySecurity.GetCurrentUser();
            request.Api = ApiTypes.AgileCrm;
            request.Request = "Get Contacts";
            var contacts = contactApi.GetContacts(request);
            var model = ToUpdateContactRequestList(contacts);
            return View("ContactList", model);
        }

        public ActionResult ContactDetails(long id)
        {
            UpdateContactRequest request = null;
            var getRequest = new GetContactRequest();
            getRequest.Id = id;
            getRequest.UserId = SynergySecurity.GetCurrentUser();
            getRequest.Api = ApiTypes.AgileCrm;
            getRequest.Request = "Get Contact";
            var model = contactApi.GetContact(getRequest);
            if (model != null)
            {
                request = new UpdateContactRequest()
                {
                    Id = model.Contact.id,
                    Property = ToConvertContactProperty(model.Contact)
                };
            }
            return View(request ?? new UpdateContactRequest());
        }

        [HttpGet]
        public ActionResult EditContact(long id)
        {
            UpdateContactRequest request = null;
            var getRequest = new GetContactRequest();
            getRequest.Id = id;
            getRequest.UserId = SynergySecurity.GetCurrentUser();
            getRequest.Api = ApiTypes.AgileCrm;
            getRequest.Request = "Get Contact";
            var model = contactApi.GetContact(getRequest);
            if (model != null)
            {
                request = new UpdateContactRequest()
                {
                    Id = model.Contact.id,
                    Property = ToConvertContactProperty(model.Contact)
                };
            }
            return View(request ?? new UpdateContactRequest());
        }

        [HttpPost]
        public ActionResult EditContact(UpdateContactRequest model)
        {
            model.UserId = SynergySecurity.GetCurrentUser();
            model.Api = ApiTypes.AgileCrm;
            model.Request = "Update Contact";
            contactApi.UpdateContactProperty(model);
            return RedirectToAction("Contacts");
        }

        [HttpGet]
        public ActionResult ContactDelete(long id)
        {
            UpdateContactRequest request = null;
            var getRequest = new GetContactRequest();
            getRequest.Id = id;
            getRequest.UserId = SynergySecurity.GetCurrentUser();
            getRequest.Api = ApiTypes.AgileCrm;
            getRequest.Request = "Get Contact";
            var model = contactApi.GetContact(getRequest);            
            if (model != null)
            {
                request = new UpdateContactRequest()
                {
                    Id = model.Contact.id,
                    Property = ToConvertContactProperty(model.Contact)
                };
            }
            return View(request ?? new UpdateContactRequest());
        }

        [HttpPost]
        public ActionResult ContactDelete(long id, FormCollection collection)
        {
            var request = new DeleteContactRequest();
            request.Id = id;
            request.UserId = SynergySecurity.GetCurrentUser();
            request.Api = ApiTypes.AgileCrm;
            request.Request = "Delete Contact";
            contactApi.DeleteContact(request);
            return RedirectToAction("Contacts");
        }

        [HttpGet]
        public ActionResult AddContact()
        {
            return View();
        }

        [HttpPost]
        public ActionResult AddContact(CreateContactRequest model)
        {
            model.UserId = SynergySecurity.GetCurrentUser();
            model.Api = ApiTypes.AgileCrm;
            model.Request = "Create Contact";
            contactApi.AddContact(model);
            return RedirectToAction("Contacts");
        }

        #endregion

        #region Deal
        public ActionResult Deals()
        {
            var model = dealApi.GetDeals();
            return View(model);
        }

        public ActionResult DealDetail(long id)
        {
            var deal = dealApi.GetDeal(id);
            return View(deal);
        }

        public ActionResult EditDeal(long id)
        {
            var deal = dealApi.GetDeal(id);
            var model = ToUpdateDealRequest(deal);
            return View(model);
        }

        [HttpPost]
        public ActionResult EditDeal(UpdateDealRequest model)
        {
            dealApi.UpdateDeal(model);
            return RedirectToAction("Deals");
        }

        public ActionResult DeleteDeal(long id)
        {
            var deal = dealApi.GetDeal(id);
            return View(deal);
        }

        [HttpPost]
        public ActionResult DeleteDeal(long id, FormCollection collection)
        {
            dealApi.DeleteDeal(id);
            return RedirectToAction("Deals");
        }

        public ActionResult CreateDeal()
        {
            return View();
        }

        [HttpPost]
        public ActionResult CreateDeal(DealRequest model)
        {
            dealApi.AddDeal(model);
            return RedirectToAction("Deals");
        }

        #endregion

        #region private

        private List<UpdateContactRequest> ToUpdateContactRequestList(GetContactsResponse response)
        {
            List<Contact> contacts = response.Contacts;
            List<UpdateContactRequest> model = new List<UpdateContactRequest>();
            foreach (var item in contacts)
            {
                UpdateContactRequest request = new UpdateContactRequest()
                {
                    Id = item.id,
                    Property = ToConvertContactProperty(item)
                };
                model.Add(request);
            }
            return model;
        }

        private ContactProperty ToConvertContactProperty(Contact model)
        {
            var address = model.properties.Where(x => x.name == "address").Select(x => x.value).FirstOrDefault();
            return new ContactProperty()
                    {
                        Address = address != null ? JsonConvert.DeserializeObject<Address>(address) : new Address(),
                        Companies = model.properties.Where(x => x.type.ToLower() == "CUSTOM".ToLower() && x.name.ToLower() == "List of companies associated".ToLower()).Select(x => x.value).ToArray(),
                        Email = model.properties.Where(x => x.name.ToLower() == "email").Select(x => x.value).FirstOrDefault(),
                        FirstName = model.properties.Where(x => x.name.ToLower() == "first_name").Select(x => x.value).FirstOrDefault(),
                        LastName = model.properties.Where(x => x.name.ToLower() == "last_name").Select(x => x.value).FirstOrDefault(),
                        LinkedIn = model.properties.Where(x => x.type.ToLower() == "CUSTOM".ToLower() && x.name.ToLower() == "LINKEDIN".ToLower()).Select(x => x.value).FirstOrDefault(),
                        Phone_Home = model.properties.Where(x => x.name.ToLower() == "phone" && x.subtype.ToLower() == "home").Select(x => x.value).FirstOrDefault(),
                        Phone_Work = model.properties.Where(x => x.name.ToLower() == "phone" && x.subtype.ToLower() == "work").Select(x => x.value).FirstOrDefault(),
                        Url = model.properties.Where(x => x.name.ToLower() == "website" && x.subtype.ToLower() == "url").Select(x => x.value).FirstOrDefault(),
                        YouTube = model.properties.Where(x => x.name.ToLower() == "website" && x.subtype.ToLower() == "youtube").Select(x => x.value).FirstOrDefault(),
                    };
        }

        private UpdateDealRequest ToUpdateDealRequest(Deal model)
        {
            return new UpdateDealRequest()
            {
                id = model.id,
                contact_ids = model.contact_ids.Select(x => Convert.ToInt64(x)).ToList(),
                expected_value = model.expected_value,
                milestone = model.milestone,
                name = model.name,
                probability = model.probability
            };
        }
        #endregion
    }
}
