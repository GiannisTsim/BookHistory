using System;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Data.SqlClient;
using Dapper;

using DotNetCoreWebAPI.Models;

namespace DotNetCoreWebAPI.DataStores
{
    public class BookStore
    {

        private readonly string _connectionString;
        public BookStore(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        public async Task<IEnumerable<Book>> FindAllAsync()
        {
            using SqlConnection connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            var books = await connection.QueryAsync<Book>("SELECT BookId, Title, PublishDate FROM Book");
            return books;
        }


        public async Task<BookDetail> FindDetailAsync(int bookId)
        {
            using SqlConnection connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
           
            var bookDetail = await connection.QuerySingleOrDefaultAsync<BookDetail>(
                @"  SELECT * FROM Book 
                    WHERE BookId = @BookId",
                new { BookId = bookId }
                );
            if (bookDetail != null)
            {
                var authors = await connection.QueryAsync<string>(
                    @"  SELECT Author 
                        FROM BookAuthor 
                        WHERE BookId = @BookId 
                        AND IsObsolete = 0",
                    new { BookId = bookId }
                    );

                bookDetail.Authors = authors.AsList();
            }
            return bookDetail;
        }

        public async Task<BookDetail> UpdateAsync(int bookId, BookDetail bookDetail)
        {
            var authorsDataTable = new DataTable();
            authorsDataTable.Columns.Add("Author", typeof(string));
            foreach (string author in bookDetail.Authors)
            {
                authorsDataTable.Rows.Add(author);
            }

            using SqlConnection connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            await connection.ExecuteAsync(
                "Book_Modify_tr",
                new
                {
                    BookId = bookId,
                    NewTitle = bookDetail.Title,
                    NewDescription = bookDetail.Description,
                    NewPublishDate = bookDetail.PublishDate,
                    NewAuthors = authorsDataTable.AsTableValuedParameter("AuthorTableType")
                },
                commandType: CommandType.StoredProcedure);

            return await FindDetailAsync(bookId);
        }

    }
}
