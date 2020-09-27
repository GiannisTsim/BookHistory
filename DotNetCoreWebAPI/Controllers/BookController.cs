using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

using DotNetCoreWebAPI.Models;
using DotNetCoreWebAPI.DataStores;

namespace DotNetCoreWebAPI
{
    [ApiController]
    [Produces("application/json")]
    public class BookController : ControllerBase
    {
        private readonly BookStore _bookStore;
        public BookController(BookStore bookStore)
        {
            _bookStore = bookStore;
        }


        [HttpGet("api/books")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<Book>>> GetBooks()
        {
            IEnumerable<Book> books = await _bookStore.FindAllAsync();
            return Ok(books);
        }

        [HttpGet("api/books/{bookId}")]
        public async Task<ActionResult<BookDetail>> GetBookDetail(int bookId)
        {
            BookDetail bookDetail = await _bookStore.FindDetailAsync(bookId);
            if (bookDetail != null)
            {
                return Ok(bookDetail);
            }
            return NotFound();
        }

        [HttpPut("api/books/{bookId}")]
        public async Task<ActionResult> EditBook(int bookId, [FromBody] BookDetail bookDetail)
        {
            await _bookStore.UpdateAsync(bookId, bookDetail);
            return Ok();
        }

    }
}
