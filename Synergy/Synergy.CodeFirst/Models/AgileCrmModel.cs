using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Synergy.CodeFirst.Models
{
    public class AgileCrmModel
    {
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