using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace DotNetCoreWebAPI.Models
{
    public class HistoryQueryParams
    {
        public int? BookId { get; set; }

        public DateTime? FromDtm { get; set; }

        public DateTime? ToDtm { get; set; }

        public List<int> RecordTypes { get; set; }

        public int? PageNo { get; set; }

        public int? PageSize { get; set; }

        public string Order { get; set; }
    }
}
