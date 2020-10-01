using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DotNetCoreWebAPI.Models
{
    public class HistorySearchResult
    {
        public int TotalCount { get; set; }
        public List<HistoryRecord> HistoryRecords { get; set; }
    }
}
