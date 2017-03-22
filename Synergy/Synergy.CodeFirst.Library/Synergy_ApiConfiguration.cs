using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Security
{
    public class Synergy_ApiConfiguration
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Required]
        public string Key { get; set; }

        public string Secret { get; set; }

        public string Email { get; set; }

        public string Url { get; set; }

        public int ApiId { get; set; }

        public int UserId { get; set; }

        public bool IsActive { get; set; }

        [ForeignKey("ApiId")]
        public Synergy_Api API { get; set; }

        [ForeignKey("UserId")]
        public Synergy_User Users { get; set; }
    }
}
