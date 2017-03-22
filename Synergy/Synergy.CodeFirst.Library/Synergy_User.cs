using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Security
{
    public class Synergy_User
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int UserId { get; set; }

        public string Email { get; set; }

        public string FirstName { get; set; }

        public string LastName { get; set; }

        public int? Age { get; set; }

        public bool IsActive { get; set; }

        [Required]
        public string UserRole { get; set; }

        public ICollection<Synergy_ApiConfiguration> Synergy_ApiConfigurations { get; set; }

        public ICollection<Synergy_ApiRequestLog> Synergy_ApiRequestLogs { get; set; }
    }
}
