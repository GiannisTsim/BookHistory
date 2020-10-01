import { HttpClient, HttpParams } from "@angular/common/http";
import { Injectable } from '@angular/core';
import { ParamMap } from "@angular/router";
import { isEmpty } from "lodash-es";
import { Observable } from "rxjs";
import { environment } from "src/environments/environment";

import { Book, BookDetail } from "../models/book.model";
import { HistoryQueryParam } from "../models/history-query-param.enum";
import { HistorySearchResult } from "../models/history-search-result.model";

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
