import { Component, OnInit } from "@angular/core";

import { BookService } from "../core/services/book.service";
import { Book } from "../models/book.model";

@Component({
  selector: "app-books",
  templateUrl: "./books.component.html",
  styleUrls: ["./books.component.css"],
})
export class BooksComponent implements OnInit {
  books: Book[];

  constructor(private bookService: BookService) { }

  ngOnInit(): void {
    this.bookService.getBooks().subscribe((books) => this.books = books);

    this.bookService.updatedBook$.subscribe(updatedBook => {
      const index = this.books.findIndex(book => book.bookId === updatedBook.bookId);
      this.books = [...this.books.slice(0, index), updatedBook, ...this.books.slice(index + 1)];
    });
  }
}
