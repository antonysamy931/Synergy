using Synergy.Common.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Security;

namespace Synergy.Security
{
    public class SynergySecurity
    {
        public static bool Login(string username, string password)
        {
            return LoginUser(username, password);
        }

        public static void Logoff()
        {
            Logout();
        }

        public static bool IsAdmin()
        {
            return ValidAdmin();
        }

        public static void Create(Synergy_User user, string username)
        {
            Add(user, username);
        }

        public static void Update(int id, int? age, string email, string firstname, string lastname)
        {
            UpdateUser(id, age, email, firstname, lastname);
        }

        public static void Delete(int id)
        {
            DeleteUser(id);
        }

        public static int GetCurrentUser()
        {
            if (HttpContext.Current.User.Identity.IsAuthenticated)
                return Convert.ToInt32(HttpContext.Current.User.Identity.Name);
            else
                return int.MinValue;
        }

        public static int ToLog<T>(T model)
        {
            int RecordId = 0;
            SynergyRequest request = model as SynergyRequest;
            if (request != null)
            {
                using (var context = new SynergyDbContext())
                {
                    var ApiId = RequestApi(context, request.Api);
                    var LogId = RequestLog(context, ApiId, request);
                    RecordId = RequestHistory(context, LogId, request);
                }
            }
            return RecordId;
        }

        public static void ToUpdateLog<T>(T model, int historyId)
        {
            SynergyResponse response = model as SynergyResponse;
            if (response != null)
            {
                UpdateHistory(historyId, response);
            }
        }

        #region Private
        private static bool LoginUser(string username, string password)
        {
            using (var context = new SynergyDbContext())
            {
                var hasValue = PasswordEncription.CreateSHAHash(password);
                var user = context.Synergy_Accounts.Where(x => x.UserName == username && x.Password == hasValue).FirstOrDefault();
                if (user != null)
                {
                    FormsAuthentication.SetAuthCookie(user.UserId.ToString(), false);
                    return true;
                }
                else
                    return false;
            }
        }

        private static bool ValidAdmin()
        {
            int UserId = Convert.ToInt32(HttpContext.Current.User.Identity.Name);
            return new SynergyDbContext().Synergy_Users.Any(x => x.UserId == UserId && x.UserRole == "admin");
        }

        private static void Logout()
        {
            FormsAuthentication.SignOut();
            HttpContext.Current.Session.Clear();
            HttpContext.Current.Session.Abandon();
        }

        private static void Add(Synergy_User user, string username)
        {
            using (var _context = new SynergyDbContext())
            {
                _context.Synergy_Users.Add(user);
                _context.SaveChanges();
                Synergy_Account account = new Synergy_Account()
                {
                    IsActive = true,
                    Password = PasswordEncription.CreateSHAHash("Pa$$word"),
                    UserName = username,
                    UserId = user.UserId
                };
                _context.Synergy_Accounts.Add(account);
                _context.SaveChanges();
            }
        }

        private static void UpdateUser(int id, int? age, string email, string firstname, string lastname)
        {
            using (var _context = new SynergyDbContext())
            {
                var user = _context.Synergy_Users.Where(x => x.UserId == id && x.IsActive).FirstOrDefault();
                user.Age = age;
                user.Email = email;
                user.FirstName = firstname;
                user.LastName = lastname;
                _context.SaveChanges();
            }
        }

        private static void DeleteUser(int id)
        {
            using (var _context = new SynergyDbContext())
            {
                var user = _context.Synergy_Users.Where(x => x.UserId == id && x.IsActive).FirstOrDefault();
                user.IsActive = false;
                var account = _context.Synergy_Accounts.Where(x => x.UserId == id && x.IsActive).FirstOrDefault();
                account.IsActive = false;
                _context.SaveChanges();
            }
        }

        private static int RequestApi(SynergyDbContext context, ApiTypes api)
        {
            var apiType = context.Synergy_API.Where(x => x.Api == api.ToString() && x.IsActive).FirstOrDefault();
            if (apiType != null)
            {
                return apiType.Id;
            }
            else
            {
                Synergy_Api addApi = new Synergy_Api()
                {
                    Api = api.ToString(),
                    IsActive = true
                };
                context.Synergy_API.Add(addApi);
                return addApi.Id;
            }
        }

        private static int RequestLog(SynergyDbContext context, int apiId, SynergyRequest request)
        {
            var logDetail = context.Synergy_ApiRequestLogs.Where(x => x.UserId == request.UserId && x.ApiId == apiId && x.IsActive).FirstOrDefault();
            if (logDetail != null)
            {
                logDetail.Requests = logDetail.Requests + 1;
                context.SaveChanges();
                return logDetail.Id;
            }
            else
            {
                Synergy_ApiRequestLog log = new Synergy_ApiRequestLog()
                {
                    ApiId = apiId,
                    IsActive = true,
                    Requests = 1,
                    UserId = request.UserId
                };
                context.Synergy_ApiRequestLogs.Add(log);
                context.SaveChanges();
                return log.Id;
            }
        }

        private static int RequestHistory(SynergyDbContext context, int logId, SynergyRequest request)
        {
            Synergy_ApiHistory history = new Synergy_ApiHistory()
            {
                IsActive = true,
                LogId = logId,
                Request = request.Request,
                RequestDateTime = DateTime.UtcNow
            };
            context.Synergy_ApiHistory.Add(history);
            context.SaveChanges();
            return history.Id;
        }

        private static void UpdateHistory(int historyId, SynergyResponse response)
        {
            using (var context = new SynergyDbContext())
            {
                var history = context.Synergy_ApiHistory.Where(x => x.Id == historyId && x.IsActive).FirstOrDefault();
                if (history != null)
                {
                    history.Message = string.IsNullOrEmpty(response.Message) ? "Processed successfully." : response.Message;
                    history.Status = response.Status.ToString();
                    context.SaveChanges();
                }
            }
        }

        #endregion
    }
}
