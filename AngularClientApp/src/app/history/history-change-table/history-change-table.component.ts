import { Component, OnInit, ViewChild } from '@angular/core';
import { MatPaginator, PageEvent } from "@angular/material/paginator";
import { Sort } from "@angular/material/sort";
import { ActivatedRoute, NavigationExtras, ParamMap, Router } from "@angular/router";
import { isEqual } from "lodash-es";
import { filter, switchMap } from "rxjs/operators";

import { BookService } from "../../core/book.service";
import { HistoryChange, HistoryType } from "../../models/history-change.model";
import { Order } from "src/app/models/history-query-params.model";

@Component({
  selector: 'app-history-change-table',
  templateUrl: './history-change-table.component.html',
  styleUrls: ['./history-change-table.component.css']
})
export class HistoryChangeTableComponent implements OnInit {
  displayedColumns: string[] = ['bookId', 'updatedDtm', 'description'];

  historyTypeDescription = {
    [HistoryType.Title]: "Title changed",
    [HistoryType.Description]: "Description changed",
    [HistoryType.PublishDate]: "Publish date changed",
    [HistoryType.AuthorAdd]: "Author added",
    [HistoryType.AuthorDrop]: "Author removed",
  };

  historyChanges: HistoryChange[] = [];

  totalCount: number;

  sortOrder: Order = Order.Desc;

  paramMap: ParamMap;

  @ViewChild(MatPaginator) paginator: MatPaginator;

  constructor(private router: Router, private route: ActivatedRoute, private bookService: BookService) { }

  ngOnInit(): void {
    this.route.queryParamMap.pipe(
      filter(paramMap => paramMap.keys.length !== 0),
      switchMap(param => {
        return this.bookService.getHistoryChanges(param);
      }))
      .subscribe(historyChanges => {
        this.historyChanges = historyChanges;
      });

    this.route.queryParamMap.pipe(
      filter(paramMap => {
        return paramMap.get("bookId") !== this.paramMap?.get("bookId") ||
          paramMap.get("fromDtm") !== this.paramMap?.get("fromDtm") ||
          paramMap.get("toDtm") !== this.paramMap?.get("toDtm") ||
          !isEqual(paramMap.getAll("historyTypes"), this.paramMap?.getAll("historyTypes"));
      }),
      switchMap(paramMap => {
        this.paramMap = paramMap;
        return this.bookService.getHistoryCount(paramMap);
      }))
      .subscribe(count => {
        this.totalCount = count;
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

    const currentPageSize = parseInt(this.route.snapshot.queryParamMap.get("pageSize"), 10);
    const currentPageNo = parseInt(this.route.snapshot.queryParamMap.get("pageNo"), 10);

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
