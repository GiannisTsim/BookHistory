import { Component, OnInit } from '@angular/core';
import { AbstractControl, FormControl, FormGroup } from "@angular/forms";
import { MatSlideToggleChange } from "@angular/material/slide-toggle";
import { ActivatedRoute, NavigationExtras, Params, Router } from "@angular/router";
import { isEmpty } from "lodash-es";
import { HistoryQueryParam } from "src/app/models/history-query-param.enum";

import { RecordType } from "src/app/models/record-type.enum";

@Component({
  selector: 'app-configuration',
  templateUrl: './configuration.component.html',
  styleUrls: ['./configuration.component.css']
})
export class ConfigurationComponent implements OnInit {
  recordType = RecordType;
  typeFilterIsChecked: boolean = false;
  timePeriodFilterIsChecked: boolean = false;

  configForm = new FormGroup({
    recordTypes: new FormControl([]),
    toDtm: new FormControl(''),
    fromDtm: new FormControl(''),
  });

  constructor(private router: Router, private route: ActivatedRoute) { }

  get recordTypes(): AbstractControl {
    return this.configForm.get("recordTypes");
  }

  get fromDtm(): AbstractControl {
    return this.configForm.get("fromDtm");
  }

  get toDtm(): AbstractControl {
    return this.configForm.get("toDtm");
  }

  ngOnInit(): void {
    this.route.queryParamMap.subscribe(paramMap => {
      if (paramMap.has(HistoryQueryParam.RecordTypes)) {
        this.typeFilterIsChecked = true;
        this.recordTypes.setValue(paramMap.getAll(HistoryQueryParam.RecordTypes));
      } else {
        this.recordTypes.reset();
      }

      if (paramMap.has(HistoryQueryParam.FromDtm)) {
        this.timePeriodFilterIsChecked = true;
        this.fromDtm.setValue(paramMap.get(HistoryQueryParam.FromDtm));
      } else {
        this.fromDtm.reset();
      }

      if (paramMap.has(HistoryQueryParam.ToDtm)) {
        this.timePeriodFilterIsChecked = true;
        this.toDtm.setValue(paramMap.get(HistoryQueryParam.ToDtm));
      } else {
        this.toDtm.reset();
      }
    });
  }

  onTypeFilterToogle(event: MatSlideToggleChange) {
    this.typeFilterIsChecked = event.checked;
  }

  onTimePeriodFilterToogle(event: MatSlideToggleChange) {
    this.timePeriodFilterIsChecked = event.checked;
  }

  onSearch() {
    const queryParams: Params = {};
    let shouldResetPagination = false;

    if (!isEmpty(this.recordTypes.value) && this.typeFilterIsChecked) {
      queryParams.recordTypes = this.recordTypes.value;
      shouldResetPagination = true;
    } else {
      queryParams.recordTypes = null;
    }

    if (!isEmpty(this.fromDtm.value) && this.timePeriodFilterIsChecked) {
      queryParams.fromDtm = this.fromDtm.value;
      shouldResetPagination = true;
    } else {
      queryParams.fromDtm = null;
    }

    if (!isEmpty(this.toDtm.value) && this.timePeriodFilterIsChecked) {
      queryParams.toDtm = this.toDtm.value;
      shouldResetPagination = true;
    } else {
      queryParams.toDtm = null;
    }

    if (shouldResetPagination) {
      queryParams.pageNo = 0;
    }

    const navigationExtras: NavigationExtras = {
      queryParamsHandling: 'merge',
      queryParams
    };

    this.router.navigate(["/history"], navigationExtras);
  }

}
