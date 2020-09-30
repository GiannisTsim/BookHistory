import { Component, OnInit } from '@angular/core';
import { Sort } from "@angular/material/sort";
import { ActivatedRoute, NavigationExtras, Router } from "@angular/router";
import { filter, switchMap } from "rxjs/operators";
import { Order } from "src/app/models/history-query-params.model";

import { BookService } from "../../core/book.service";
import { HistoryChange, HistoryType } from "../../models/history-change.model";

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

  historyChanges: HistoryChange[];

  sortOrder: Order = Order.Desc;

  constructor(private router: Router, private route: ActivatedRoute, private bookService: BookService) { }

  ngOnInit(): void {
    this.route.queryParamMap.pipe(
      filter(paramMap => paramMap.keys.length !== 0),
      switchMap(param => {
        console.log("HistoryChangeTableComponent -- New query params detected, GET /history");
        return this.bookService.getHistoryChanges(param);
      }))
      .subscribe(historyChanges => {
        this.historyChanges = historyChanges;
      });
  }

  // TODO: reset pagination on sort order change
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

}
