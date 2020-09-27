import { HttpClient } from "@angular/common/http";
import { Injectable } from '@angular/core';
import { Observable } from "rxjs";
import { environment } from "src/environments/environment";

import { Book, BookDetail } from "../models/book.model";

@Injectable({
  providedIn: 'root'
})
export class BookService {

  constructor(private http: HttpClient) { }

  getBooks(): Observable<Book[]> {
    return this.http.get<Book[]>(`${environment.apiUrl}/books`);
  }

  getBookDetail(bookId: number): Observable<BookDetail> {
    return this.http.get<BookDetail>(`${environment.apiUrl}/books/${bookId}`);
  }

  editBook(bookId: number, bookDetail: BookDetail) {
    return this.http.put(`${environment.apiUrl}/books/${bookId}`, bookDetail);
  }
}
