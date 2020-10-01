using Microsoft.Extensions.Configuration;
using System;
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

        public async Task<HistorySearchResult> SearchAndCountTotalAsync(HistoryQueryParams queryParams)
        {
            var recordTypesDataTable = new DataTable();
            recordTypesDataTable.Columns.Add("RecordType", typeof(int));
            if (queryParams.RecordTypes != null)
            {
                foreach (int recordType in queryParams.RecordTypes)
                {
                    recordTypesDataTable.Rows.Add(recordType);
                }
            }

            var dnamicParams = new DynamicParameters();
            if (queryParams.BookId != null)
            {
                dnamicParams.Add("BookId", queryParams.BookId, DbType.Int32, ParameterDirection.Input);
            }
            if (queryParams.FromDtm != null)
            {
                dnamicParams.Add("FromDtm", queryParams.FromDtm, DbType.DateTime, ParameterDirection.Input);
            }
            if (queryParams.ToDtm != null)
            {
                dnamicParams.Add("ToDtm", queryParams.ToDtm, DbType.DateTime, ParameterDirection.Input);
            }
            if (queryParams.RecordTypes != null && queryParams.RecordTypes.Any())
            {
                dnamicParams.Add("RecordTypes", recordTypesDataTable.AsTableValuedParameter("RecordTypeTableType"));
            }
            if(queryParams.PageNo != null)
            {
                dnamicParams.Add("PageNo", queryParams.PageNo, DbType.Int32, ParameterDirection.Input);
            }
            if (queryParams.PageSize != null)
            {
                dnamicParams.Add("PageSize", queryParams.PageSize, DbType.Int32, ParameterDirection.Input);
            }
            if (!String.IsNullOrWhiteSpace(queryParams.Order))
            {
                dnamicParams.Add("Order", queryParams.Order, DbType.String, ParameterDirection.Input);
            }

            dnamicParams.Add("TotalCount", dbType: DbType.Int32, direction: ParameterDirection.Output);

            HistorySearchResult historySearchResult = new HistorySearchResult();
            using SqlConnection connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            historySearchResult.HistoryRecords = (await connection.QueryAsync<HistoryRecord>(
                "BookHistory_SearchAndCountTotal",
                dnamicParams,
                commandType: CommandType.StoredProcedure)).ToList();

            historySearchResult.TotalCount = dnamicParams.Get<int>("TotalCount");

            return historySearchResult;
        }
    }
}
