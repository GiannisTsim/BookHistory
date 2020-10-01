import { HttpClient, HttpParams } from "@angular/common/http";
import { Injectable } from '@angular/core';
import { ParamMap } from "@angular/router";
import { isEmpty } from "lodash-es";
import { Observable, Subject } from "rxjs";
import { tap } from "rxjs/operators";
import { environment } from "src/environments/environment";

import { Book } from "../models/book.model";
import { BookDetail } from "../models/book-detail.model";
import { HistoryQueryParam } from "../models/history-query-param.enum";
import { HistorySearchResult } from "../models/history-search-result.model";

@Injectable({
  providedIn: 'root'
})
export class BookService {

  private updatedBookSubject: Subject<Book> = new Subject<Book>();
  readonly updatedBook$: Observable<Book> = this.updatedBookSubject.asObservable();

  constructor(private http: HttpClient) { }

  getBooks(): Observable<Book[]> {
    return this.http.get<Book[]>(`${environment.apiUrl}/books`);
  }

  getBookDetail(bookId: number): Observable<BookDetail> {
    return this.http.get<BookDetail>(`${environment.apiUrl}/books/${bookId}`);
  }

  editBook(bookId: number, bookDetail: BookDetail): Observable<BookDetail> {
    return this.http.put<BookDetail>(`${environment.apiUrl}/books/${bookId}`, bookDetail).pipe(
      tap(bookDetail => {
        this.updatedBookSubject.next({ bookId: bookDetail.bookId, title: bookDetail.title, publishDate: bookDetail.publishDate });
      })
    );

  }

  searchHistory(paramMap?: ParamMap): Observable<HistorySearchResult> {
    let httpParams = new HttpParams();
    paramMap.keys
      .filter(key => !isEmpty(paramMap.get(key)))
      .forEach(key => {
        if (key === HistoryQueryParam.RecordTypes) {
          paramMap.getAll(HistoryQueryParam.RecordTypes).forEach(recordType => {
            httpParams = httpParams.append(key, recordType);
          });
        } else {
          httpParams = httpParams.append(key, paramMap.get(key));
        }
      });
    return this.http.get<HistorySearchResult>(`${environment.apiUrl}/history`, { params: httpParams });
  }
}
