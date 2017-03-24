using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Synergy.Admin.New.Models
{
    public class HubSpotModel
    {
        public int Id { get; set; }

        [Required]
        [Display(Name="Hubspot Key")]
        public string Key { get; set; }

        [Required]
        [Display(Name="Hubspot Secret")]
        public string Secret { get; set; }
    }
}