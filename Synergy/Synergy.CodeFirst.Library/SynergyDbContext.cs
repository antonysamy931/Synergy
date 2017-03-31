using Synergy.Common.Model;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Security
{
    public class SynergyDbContext : DbContext
    {
        public SynergyDbContext()
            : base("Synergy.Connection")
        {
            Database.SetInitializer(new SynergyDbInitializer());
        }

        public DbSet<Synergy_User> Synergy_Users { get; set; }
        public DbSet<Synergy_Account> Synergy_Accounts { get; set; }
        public DbSet<Synergy_Api> Synergy_API { get; set; }
        public DbSet<Synergy_ApiConfiguration> Synergy_ApiConfigurations { get; set; }
        public DbSet<Synergy_ApiRequestLog> Synergy_ApiRequestLogs { get; set; }
        public DbSet<Synergy_ApiHistory> Synergy_ApiHistory { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            //modelBuilder.Entity<Synergy_Account>()
            //    .Property(c => c.AccountId)
            //    .HasDatabaseGeneratedOption(DatabaseGeneratedOption.Identity);

            base.OnModelCreating(modelBuilder);
        }
    }

    public class SynergyDbInitializer : DropCreateDatabaseAlways<SynergyDbContext>
    {
        public override void InitializeDatabase(SynergyDbContext context)
        {
            if (!context.Database.Exists())
            {
                base.InitializeDatabase(context);
            }
        }

        protected override void Seed(SynergyDbContext context)
        {            
            context.Synergy_API.Add(new Synergy_Api() { Api = ApiTypes.AgileCrm.ToString() });
            context.Synergy_API.Add(new Synergy_Api() { Api = ApiTypes.Infusion.ToString() });
            context.Synergy_API.Add(new Synergy_Api() { Api = ApiTypes.HubSpot.ToString() });

            var Synergy_User = new Synergy_User() { IsActive = true, FirstName = "admin", LastName = "admin", UserRole = "admin" };
            context.Synergy_Users.Add(Synergy_User);
            context.SaveChanges();
            context.Synergy_Accounts.Add(new Synergy_Account() { IsActive = true, UserId = Synergy_User.UserId, 
                Password = PasswordEncription.CreateSHAHash("BistroMDSystem"), UserName = "System" });
            context.SaveChanges();
            base.Seed(context);
        }
    }
}
