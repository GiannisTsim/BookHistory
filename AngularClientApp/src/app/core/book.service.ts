import { HttpClient, HttpParams } from "@angular/common/http";
import { Injectable } from '@angular/core';
import { ParamMap } from "@angular/router";
import { isEmpty } from "lodash-es";
import { Observable } from "rxjs";
import { environment } from "src/environments/environment";

import { Book, BookDetail } from "../models/book.model";
import { HistoryChange } from "../models/history-change.model";
import { HistoryQueryParams } from "../models/history-query-params.model";

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

  private buildHttpParams(paramMap: ParamMap) {
    let httpParams = new HttpParams();
    paramMap.keys
      .filter(key => !isEmpty(paramMap.get(key)))
      .forEach(key => {
        if (key === "historyTypes") {
          paramMap.getAll("historyTypes").forEach(historyType => {
            httpParams = httpParams.append(key, historyType);
          });
        } else {
          httpParams = httpParams.append(key, paramMap.get(key));
        }
      });
    return httpParams;
  }

  getHistoryChanges(paramMap?: ParamMap): Observable<HistoryChange[]> {
    return this.http.get<HistoryChange[]>(`${environment.apiUrl}/history`, { params: this.buildHttpParams(paramMap) });
  }

  getHistoryCount(paramMap?: ParamMap): Observable<number> {
    return this.http.get<number>(`${environment.apiUrl}/history/count`, { params: this.buildHttpParams(paramMap) });
  }
}
