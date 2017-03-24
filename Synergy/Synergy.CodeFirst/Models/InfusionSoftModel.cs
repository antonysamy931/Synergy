using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Synergy.Admin.Models
{
    public class InfusionSoftModel
    {
        public int Id { get; set; }

        [Required]
        [Display(Name="Infusion Key")]
        public string Key { get; set; }

        [Required]
        [Display(Name="Infusion Secret")]
        public string Secret { get; set; }
    }
}