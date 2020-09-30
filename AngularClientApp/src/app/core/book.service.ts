import { HttpClient, HttpParams } from "@angular/common/http";
import { Injectable } from '@angular/core';
import { ParamMap } from "@angular/router";
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

  getHistoryChanges(paramMap?: ParamMap): Observable<HistoryChange[]> {
    let httpParams = new HttpParams();
    paramMap.keys.forEach(key => {
      // console.log(`${key}: ${paramMap.get(key)}`);
      httpParams = httpParams.append(key, paramMap.get(key));
    });
    return this.http.get<HistoryChange[]>(`${environment.apiUrl}/history`, { params: httpParams });
  }

  getHistoryCount(paramMap?: ParamMap): Observable<number> {
    let httpParams = new HttpParams();
    paramMap.keys.forEach(key => {
      // console.log(`${key}: ${paramMap.get(key)}`);
      httpParams = httpParams.append(key, paramMap.get(key));
    });
    return this.http.get<number>(`${environment.apiUrl}/history/count`, { params: httpParams });
  }



  // getHistoryChanges(historyQueryParams?: HistoryQueryParams): Observable<HistoryChange[]> {
  //   const params = new HttpParams();

  //   historyQueryParams && Object.keys(historyQueryParams).forEach(key => {
  //     params.append(key, historyQueryParams[key]);
  //   });

  //   console.log(params.toString());

  //   return this.http.get<HistoryChange[]>(`${environment.apiUrl}/history`, { params });
  // }
}
