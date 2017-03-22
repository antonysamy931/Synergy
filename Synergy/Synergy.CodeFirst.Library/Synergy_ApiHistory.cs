using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Security
{
    public class Synergy_ApiHistory
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        public string Status { get; set; }

        public string Request { get; set; }

        public string Message { get; set; }

        public DateTime RequestDateTime { get; set; }

        public int LogId { get; set; }

        public bool IsActive { get; set; }

        [ForeignKey("LogId")]
        public Synergy_ApiRequestLog Logs { get; set; }
    }
}
