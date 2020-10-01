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
        public async Task<ActionResult<HistorySearchResult>> GetHistory([FromQuery] HistoryQueryParams queryParams)
        {
            HistorySearchResult result = await _historyStore.SearchAndCountTotalAsync(queryParams);
            return Ok(result);
        }

    }
}
