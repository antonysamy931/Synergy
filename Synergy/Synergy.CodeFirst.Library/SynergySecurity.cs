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
        #endregion
    }
}
