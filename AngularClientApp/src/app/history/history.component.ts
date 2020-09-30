import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, NavigationExtras, Router } from "@angular/router";

import { Order } from "../models/history-query-params.model";

@Component({
  selector: 'app-history',
  templateUrl: './history.component.html',
  styleUrls: ['./history.component.css']
})
export class HistoryComponent implements OnInit {

  constructor(private router: Router, private route: ActivatedRoute) { }

  ngOnInit(): void {
    if (this.route.snapshot.queryParamMap.keys.length === 0) {
      const navigationExtras: NavigationExtras = {
        queryParamsHandling: 'merge',
        queryParams: { pageNo: 0, pageSize: 10, order: Order.Desc }
      };
      this.router.navigate(["/history"], navigationExtras);
    }
  }

}
