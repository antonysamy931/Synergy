using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Security
{
    public class Synergy_ApiRequestLog
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        public int UserId { get; set; }

        public int ApiId { get; set; }

        public int Requests { get; set; }

        public bool IsActive { get; set; }

        [ForeignKey("UserId")]
        public Synergy_User Users { get; set; }

        [ForeignKey("ApiId")]
        public Synergy_Api API { get; set; }

        public ICollection<Synergy_ApiHistory> ApiHistory { get; set; }
    }
}
