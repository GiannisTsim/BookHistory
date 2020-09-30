import { Component, OnInit, ViewChild } from '@angular/core';
import { MatPaginator, PageEvent } from "@angular/material/paginator";
import { ActivatedRoute, NavigationExtras, ParamMap, Router } from "@angular/router";
import { isEqual } from "lodash-es";
import { filter, switchMap, tap } from "rxjs/operators";

import { BookService } from "../core/book.service";

@Component({
  selector: 'app-history',
  templateUrl: './history.component.html',
  styleUrls: ['./history.component.css']
})
export class HistoryComponent implements OnInit {

  paramMap: ParamMap;

  @ViewChild(MatPaginator) paginator: MatPaginator;

  constructor(private router: Router, private route: ActivatedRoute, private bookService: BookService) { }

  ngOnInit(): void {
    if (this.route.snapshot.queryParamMap.keys.length === 0) {
      const navigationExtras: NavigationExtras = {
        queryParamsHandling: 'merge',
        queryParams: { pageNo: 0, pageSize: 10 }
      };
      this.router.navigate(["/history"], navigationExtras);
    }

    this.route.queryParamMap.pipe(
      filter(paramMap => {
        return paramMap.get("bookId") !== this.paramMap?.get("bookId") ||
          paramMap.get("fromDtm") !== this.paramMap?.get("fromDtm") ||
          paramMap.get("toDtm") !== this.paramMap?.get("toDtm") ||
          !isEqual(paramMap.getAll("historyTypes"), this.paramMap?.getAll("historyTypes"));
      }),
      switchMap(paramMap => {
        this.paramMap = paramMap;
        console.log(this.paramMap);
        console.log("HistoryComponent -- New query params detected");
        return this.bookService.getHistoryCount(paramMap);
      }))
      .subscribe(count => {
        this.paginator.length = count;
      });
  }

  onPageEvent(event: PageEvent) {
    // console.log(event);
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
