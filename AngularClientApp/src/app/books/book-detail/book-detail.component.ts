import { Component, OnInit } from '@angular/core';
import { FormArray, FormControl, FormGroup } from "@angular/forms";
import { ActivatedRoute } from "@angular/router";
import { isEqual } from "lodash-es";
import { switchMap } from "rxjs/operators";

import { BookService } from "src/app/core/book.service";
import { Book, BookDetail } from "src/app/models/book.model";

@Component({
  selector: 'app-book-detail',
  templateUrl: './book-detail.component.html',
  styleUrls: ['./book-detail.component.css']
})
export class BookDetailComponent implements OnInit {
  bookDetail: BookDetail;

  bookForm = new FormGroup({
    title: new FormControl(''),
    description: new FormControl(''),
    publishDate: new FormControl(''),
    authors: new FormArray([])
  });

  constructor(private route: ActivatedRoute, private bookService: BookService) { }

  get authorsFormArray() {
    return this.bookForm.get('authors') as FormArray;
  }

  ngOnInit(): void {
    this.route.paramMap.pipe(
      switchMap(param => {
        const bookId = parseInt(param.get("bookId"), 10);
        return this.bookService.getBookDetail(bookId);
      }))
      .subscribe(bookDetail => {
        this.bookDetail = bookDetail;
        this.resetForm();
      });
  }

  onSubmit() {
    console.warn(this.bookForm.value);
    this.bookService.editBook(this.bookDetail.bookId, this.bookForm.value as BookDetail)
      .subscribe(
        () => {
          // TODO: communicate change through shared service, cannot use event emmiter because this is a routed component
          // if (!isEqual(this.bookDetail as Book, this.bookForm.value as Book)) {
          //   this.bookChanged.emit(this.bookDetail as Book);
          // }
          this.bookDetail = { bookId: this.bookDetail.bookId, ...this.bookForm.value };
          this.bookForm.markAsPristine();
        },
        error => console.log(error)
      );
  }

  resetForm() {
    this.bookForm.get("title").setValue(this.bookDetail.title);
    this.bookForm.get("description").setValue(this.bookDetail.description);
    this.bookForm.get("publishDate").setValue(this.bookDetail.publishDate);
    this.authorsFormArray.clear();
    this.bookDetail.authors.forEach(author => this.authorsFormArray.push(new FormControl(author)));
    this.bookForm.markAsPristine();
  }

  addAuthor() {
    this.authorsFormArray.push(new FormControl(""));
    this.bookForm.markAsDirty();
  }

  removeAuthor(index: number) {
    this.authorsFormArray.removeAt(index);
    this.bookForm.markAsDirty();
  }

  onAuthorBlur(index: number) {
    this.authorsFormArray.at(index).value.trim() === "" && this.removeAuthor(index);
  }
}
