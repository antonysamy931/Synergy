using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.CodeFirst.Library
{
    public class SynergyDbContext : DbContext
    {
        public SynergyDbContext()
            : base("Synergy.Connection")
        {
        }

        public DbSet<Synergy_User> Synergy_Users { get; set; }
        public DbSet<Synergy_Account> Synergy_Accounts { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            //modelBuilder.Entity<Synergy_Account>()
            //    .Property(c => c.AccountId)
            //    .HasDatabaseGeneratedOption(DatabaseGeneratedOption.Identity);

            base.OnModelCreating(modelBuilder);
        }
    }
}
