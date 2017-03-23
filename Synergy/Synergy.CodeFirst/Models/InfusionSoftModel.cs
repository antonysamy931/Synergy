using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Synergy.CodeFirst.Models
{
    public class InfusionSoftModel
    {
        [Required]
        [Display(Name="Infusion Key")]
        public string Key { get; set; }

        [Required]
        [Display(Name="Infusion Secret")]
        public string Secret { get; set; }
    }
}