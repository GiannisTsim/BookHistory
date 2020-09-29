import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from "@angular/router";
import { switchMap } from "rxjs/operators";

import { BookService } from "../core/book.service";
import { HistoryChange, HistoryType } from "../models/history-change.model";
import { HistoryQueryParams } from "../models/history-query-params.model";

@Component({
  selector: 'app-history',
  templateUrl: './history.component.html',
  styleUrls: ['./history.component.css']
})
export class HistoryComponent implements OnInit {
  displayedColumns: string[] = ['bookId', 'updatedDtm', 'description'];

  historyTypeDescription = {
    [HistoryType.Title]: "Title changed",
    [HistoryType.Description]: "Description changed",
    [HistoryType.PublishDate]: "Publish date changed",
    [HistoryType.AuthorAdd]: "Author added",
    [HistoryType.AuthorDrop]: "Author removed",
  };

  historyChanges: HistoryChange[];

  constructor(private route: ActivatedRoute, private bookService: BookService) { }

  ngOnInit(): void {
    this.route.queryParamMap.pipe(
      switchMap(param => {
        // const historyQueryParams: HistoryQueryParams = {};
        // param.has("bookId") && !isNaN(parseInt(param.get("bookId"), 10))
        //   && (historyQueryParams.bookId = parseInt(param.get("bookId"), 10));
        // param.has("fromDtm") && (historyQueryParams.fromDtm = new Date(param.get("fromDtm")));
        // param.has("toDtm") && (historyQueryParams.toDtm = new Date(param.get("toDtm")));
        // historyQueryParams.historyTypes = param.getAll("historyTypes").map(type => type as HistoryType)
        console.log(param.keys);
        return this.bookService.getHistoryChanges(param);
      }))
      .subscribe(historyChanges => {
        this.historyChanges = historyChanges;
      });
  }

}
