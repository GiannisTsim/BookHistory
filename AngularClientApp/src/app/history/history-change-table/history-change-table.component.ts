import { Component, OnInit, ViewChild } from '@angular/core';
import { MatPaginator, PageEvent } from "@angular/material/paginator";
import { Sort } from "@angular/material/sort";
import { ActivatedRoute, NavigationExtras, ParamMap, Router } from "@angular/router";
import { filter, switchMap } from "rxjs/operators";

import { BookService } from "../../core/services/book.service";
import { HistorySearchResult } from "src/app/models/history-search-result.model";
import { RecordType } from "src/app/models/record-type.enum";
import { Order } from "src/app/models/order.enum";
import { HistoryQueryParam } from "src/app/models/history-query-param.enum";

@Component({
  selector: 'app-history-change-table',
  templateUrl: './history-change-table.component.html',
  styleUrls: ['./history-change-table.component.css']
})
export class HistoryChangeTableComponent implements OnInit {
  displayedColumns: string[] = ['bookId', 'updatedDtm', 'description'];

  recordTypeDescription = {
    [RecordType.Title]: "Title changed",
    [RecordType.Description]: "Description changed",
    [RecordType.PublishDate]: "Publish date changed",
    [RecordType.AuthorAdd]: "Author added",
    [RecordType.AuthorDrop]: "Author removed",
  };

  historySearchResult: HistorySearchResult;

  sortOrder: Order = Order.Desc;

  paramMap: ParamMap;

  @ViewChild(MatPaginator) paginator: MatPaginator;

  constructor(private router: Router, private route: ActivatedRoute, private bookService: BookService) { }

  ngOnInit(): void {
    this.route.queryParamMap.pipe(
      filter(paramMap => paramMap.keys.length !== 0),
      switchMap(param => {
        return this.bookService.searchHistory(param);
      }))
      .subscribe(historySearchResult => {
        this.historySearchResult = historySearchResult;
      });
  }

  onSortOrderChange(event: Sort) {
    const navigationExtras: NavigationExtras = {
      queryParamsHandling: 'merge',
    };

    const currentSortOrder = this.route.snapshot.queryParamMap.get("order");

    if (event.direction !== currentSortOrder) {
      navigationExtras.queryParams = { order: event.direction };
    }

    this.router.navigate(["/history"], navigationExtras);
  }

  onPageEvent(event: PageEvent) {
    const navigationExtras: NavigationExtras = {
      queryParamsHandling: 'merge',
    };

    const currentPageSize = parseInt(this.route.snapshot.queryParamMap.get(HistoryQueryParam.PageSize), 10);
    const currentPageNo = parseInt(this.route.snapshot.queryParamMap.get(HistoryQueryParam.PageNo), 10);

    if (event.pageSize !== currentPageSize) {
      this.paginator.firstPage();
      navigationExtras.queryParams = { pageNo: 0, pageSize: event.pageSize };
    }
    else if (event.pageIndex !== currentPageNo) {
      navigationExtras.queryParams = { pageNo: event.pageIndex };
    }

    this.router.navigate(["/history"], navigationExtras);
  }

}
