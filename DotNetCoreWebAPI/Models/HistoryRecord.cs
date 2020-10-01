using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DotNetCoreWebAPI.Models
{
    public class HistoryRecord
    {
        public int BookId { get; set; }

        public DateTime UpdatedDtm { get; set; }

        public int RecordType { get; set; }

        public string Change { get; set; }
    }
}
