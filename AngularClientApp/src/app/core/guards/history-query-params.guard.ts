import { Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, UrlTree, Router, NavigationExtras } from '@angular/router';
import { Observable } from 'rxjs';

import { HistoryQueryParam } from "src/app/models/history-query-param.enum";
import { Order } from "src/app/models/order.enum";

@Injectable({
  providedIn: 'root'
})
export class HistoryQueryParamsGuard implements CanActivate {

  constructor(private router: Router) { }

  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot): Observable<boolean | UrlTree> | Promise<boolean | UrlTree> | boolean | UrlTree {
    const paramMap = route.queryParamMap;
    const pageNo = parseInt(paramMap.get(HistoryQueryParam.PageNo), 10);
    const pageSize = parseInt(paramMap.get(HistoryQueryParam.PageSize), 10);
    const order = paramMap.get(HistoryQueryParam.Order);

    const orderIsValid = (order == Order.Asc || order == Order.Desc);


    if (isNaN(pageNo) || isNaN(pageSize) || !orderIsValid) {
      // console.log("##### ROUTE GUARD HIT #######");
      // console.log(`${pageNo}, ${pageSize}, ${order}`);
      const navigationExtras: NavigationExtras = {
        queryParamsHandling: 'merge',
        queryParams: {
          pageNo: pageNo || 0,
          pageSize: pageSize || 10,
          order: orderIsValid ? order : Order.Desc
        }
      };
      this.router.navigate(["/history"], navigationExtras);
      return false;
    }
    return true;
  }

}
