using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Synergy.Admin.Models
{
    public class AgileCrmModel
    {
        public int Id { get; set; }

        [Required]
        [Display(Name="Agile Key")]
        public string Key { get; set; }

        [Required]
        [DataType(DataType.EmailAddress)]
        [Display(Name="Email Address")]
        public string Email { get; set; }

        [Required]
        [DataType(DataType.Url)]
        public string Url { get; set; }
    }
}