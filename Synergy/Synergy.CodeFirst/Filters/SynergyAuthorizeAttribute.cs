using Synergy.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace Synergy.CodeFirst.Filters
{
    public class SynergyAuthorizeAttribute : FilterAttribute, IAuthorizationFilter
    {
        public string Role { get; set; }

        public SynergyAuthorizeAttribute()
        {
        }

        public SynergyAuthorizeAttribute(string role)
        {
            Role = role;
        }

        public void OnAuthorization(AuthorizationContext filterContext)
        {
            if (HttpContext.Current.User != null &&
                HttpContext.Current.User.Identity.IsAuthenticated)
            {
                if (!string.IsNullOrEmpty(Role))
                {
                    using (var context = new SynergyDbContext())
                    {
                        if (!context.Synergy_Users.Any(x => x.UserRole.ToLower() == Role.ToLower()))
                            throw new UnauthorizedAccessException("Don't have to permission to access this page.");
                    }
                }
            }
            else
                filterContext.Result = new RedirectToRouteResult(
                new RouteValueDictionary 
                { 
                    { "controller", "Account" }, 
                    { "action", "Login" }
                });
        }
    }
}
