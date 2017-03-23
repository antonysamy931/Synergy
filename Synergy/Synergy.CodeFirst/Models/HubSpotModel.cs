using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Synergy.CodeFirst.Models
{
    public class HubSpotModel
    {
        [Required]
        [Display(Name="Hubspot Key")]
        public string Key { get; set; }

        [Required]
        [Display(Name="Hubspot Secret")]
        public string Secret { get; set; }
    }
}