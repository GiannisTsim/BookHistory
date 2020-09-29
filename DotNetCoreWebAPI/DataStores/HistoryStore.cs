using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Dapper;

using DotNetCoreWebAPI.Models;

namespace DotNetCoreWebAPI.DataStores
{
    public class HistoryStore
    {

        private readonly string _connectionString;
        public HistoryStore(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        public async Task<IEnumerable<History>> FindAsync(HistoryQueryParams queryParams)
        {
            var historyTypesDataTable = new DataTable();
            historyTypesDataTable.Columns.Add("HistoryType", typeof(int));
            if (queryParams.HistoryTypes != null)
            {
                foreach (int historyType in queryParams.HistoryTypes)
                {
                    historyTypesDataTable.Rows.Add(historyType);
                }
            }

            using SqlConnection connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            var history = await connection.QueryAsync<History>(
                "BookHistory_Search",
                new
                {
                    queryParams.BookId,
                    queryParams.FromDtm,
                    queryParams.ToDtm,
                    HistoryTypes = historyTypesDataTable.AsTableValuedParameter("HistoryTypeTableType"),
                    queryParams.PageNo,
                    queryParams.PageSize,
                    queryParams.Order
                },
                commandType: CommandType.StoredProcedure);
            return history;
        }
    }
}
