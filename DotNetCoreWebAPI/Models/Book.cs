using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace DotNetCoreWebAPI.Models
{

    public class Book
    {
        public int BookId { get; set; }

        [Required]
        [StringLength(100)]
        public string Title { get; set; }

        [Required]
        public DateTime PublishDate { get; set; }
    }


    public class BookDetail : Book
    {
        [Required]
        [StringLength(256)]
        public string Description { get; set; }

        public DateTime UpdatedDtm { get; set; }

        [Required]
        public List<string> Authors { get; set; }
    }
}
