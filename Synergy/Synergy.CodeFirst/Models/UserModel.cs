using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Synergy.Admin.Models
{
    public class UserModel
    {
        public int Id { get; set; }
        [Required]
        [Display(Name="Username")]
        public string UserName { get; set; }
        [Display(Name="First name")]
        public string FirstName { get; set; }
        [Display(Name = "Last name")]
        public string LastName { get; set; }
        [EmailAddress]        
        public string Email { get; set; }
        public int? Age { get; set; }
    }
}