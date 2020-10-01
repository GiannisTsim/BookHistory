import { Component, OnInit } from '@angular/core';
import { PageEvent } from "@angular/material/paginator";
import { Sort } from "@angular/material/sort";
import { ActivatedRoute, NavigationExtras, Router } from "@angular/router";
import { switchMap } from "rxjs/operators";

import { BookService } from "../../core/services/book.service";
import { HistorySearchResult } from "src/app/models/history-search-result.model";
import { RecordType } from "src/app/models/record-type.enum";
import { Order } from "src/app/models/order.enum";
import { HistoryQueryParam } from "src/app/models/history-query-param.enum";

@Component({
  selector: 'app-history-record-table',
  templateUrl: './history-record-table.component.html',
  styleUrls: ['./history-record-table.component.css']
})
export class HistoryRecordTableComponent implements OnInit {
  displayedColumns: string[] = ['bookId', 'updatedDtm', 'description'];

  recordTypeDescription = {
    [RecordType.Title]: "Title changed",
    [RecordType.Description]: "Description changed",
    [RecordType.PublishDate]: "Publish date changed",
    [RecordType.AuthorAdd]: "Author added",
    [RecordType.AuthorDrop]: "Author removed",
  };

  historySearchResult: HistorySearchResult;

  order: Order;
  pageNo: number;
  pageSize: number;

  constructor(private router: Router, private route: ActivatedRoute, private bookService: BookService) { }

  ngOnInit(): void {
    this.route.queryParamMap.pipe(
      switchMap(paramMap => {
        this.pageNo = parseInt(paramMap.get(HistoryQueryParam.PageNo), 10);
        this.pageSize = parseInt(paramMap.get(HistoryQueryParam.PageSize), 10);
        this.order = paramMap.get(HistoryQueryParam.Order) as Order;
        return this.bookService.searchHistory(paramMap);
      }))
      .subscribe(historySearchResult => {
        this.historySearchResult = historySearchResult;
      });
  }

  onSortOrderChange(event: Sort) {
    const navigationExtras: NavigationExtras = {
      queryParamsHandling: 'merge',
    };

    if (event.direction !== this.order) {
      navigationExtras.queryParams = { pageNo: 0, order: event.direction };
    }

    this.router.navigate(["/history"], navigationExtras);
  }

  onPageEvent(event: PageEvent) {
    const navigationExtras: NavigationExtras = {
      queryParamsHandling: 'merge',
    };

    if (event.pageSize !== this.pageSize) {
      navigationExtras.queryParams = { pageNo: 0, pageSize: event.pageSize };
    }
    else if (event.pageIndex !== this.pageNo) {
      navigationExtras.queryParams = { pageNo: event.pageIndex };
    }

    this.router.navigate(["/history"], navigationExtras);
  }

}
