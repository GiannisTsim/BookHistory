using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

using DotNetCoreWebAPI.DataStores;
using DotNetCoreWebAPI.Models;

namespace DotNetCoreWebAPI.Controllers
{
    [ApiController]
    [Produces("application/json")]
    public class HistoryController : ControllerBase
    {
        private readonly HistoryStore _historyStore;
        public HistoryController(HistoryStore historyStore)
        {
            _historyStore = historyStore;
        }


        [HttpGet("api/history")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<History>>> GetHistory([FromQuery] HistoryQueryParams queryParams)
        {
            IEnumerable<History> history = await _historyStore.FindAsync(queryParams);
            return Ok(history);
        }


        [HttpGet("api/history/count")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<int>> GetHistoryCount([FromQuery] HistoryQueryParams queryParams)
        {
            int count = await _historyStore.CountAsync(queryParams);
            return Ok(count);
        }

    }
}
