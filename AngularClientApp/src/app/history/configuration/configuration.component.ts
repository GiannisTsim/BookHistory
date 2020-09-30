import { Component, OnInit } from '@angular/core';
import { AbstractControl, FormControl, FormGroup } from "@angular/forms";
import { MatSlideToggleChange } from "@angular/material/slide-toggle";
import { ActivatedRoute, NavigationExtras, Params, Router } from "@angular/router";
import { isEmpty } from "lodash-es";

import { HistoryType } from "src/app/models/history-change.model";

@Component({
  selector: 'app-configuration',
  templateUrl: './configuration.component.html',
  styleUrls: ['./configuration.component.css']
})
export class ConfigurationComponent implements OnInit {
  historyType = HistoryType;
  typeFilterIsChecked: boolean = false;
  timePeriodFilterIsChecked: boolean = false;

  configForm = new FormGroup({
    historyTypes: new FormControl([]),
    toDtm: new FormControl(''),
    fromDtm: new FormControl(''),
  });

  constructor(private router: Router, private route: ActivatedRoute) { }

  get historyTypes(): AbstractControl {
    return this.configForm.get("historyTypes");
  }

  get fromDtm(): AbstractControl {
    return this.configForm.get("fromDtm");
  }

  get toDtm(): AbstractControl {
    return this.configForm.get("toDtm");
  }

  ngOnInit(): void {
    this.route.queryParamMap.subscribe(paramMap => {
      if (paramMap.has("historyTypes")) {
        this.typeFilterIsChecked = true;
        this.historyTypes.setValue(paramMap.getAll("historyTypes").map(type => parseInt(type, 10)));
      } else {
        this.historyTypes.reset();
      }

      if (paramMap.has("fromDtm")) {
        this.timePeriodFilterIsChecked = true;
        this.fromDtm.setValue(paramMap.get("fromDtm"));
      } else {
        this.fromDtm.reset();
      }

      if (paramMap.has("toDtm")) {
        this.timePeriodFilterIsChecked = true;
        this.toDtm.setValue(paramMap.get("toDtm"));
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

    if (!isEmpty(this.historyTypes.value) && this.typeFilterIsChecked) {
      queryParams.historyTypes = this.historyTypes.value;
    } else {
      queryParams.historyTypes = null;
    }
    if (!isEmpty(this.fromDtm.value) && this.timePeriodFilterIsChecked) {
      queryParams.fromDtm = this.fromDtm.value;
    } else {
      queryParams.fromDtm = null;
    }
    if (!isEmpty(this.toDtm.value) && this.timePeriodFilterIsChecked) {
      queryParams.toDtm = this.toDtm.value;
    } else {
      queryParams.toDtm = null;
    }

    const navigationExtras: NavigationExtras = {
      queryParamsHandling: 'merge',
      queryParams
    };

    this.router.navigate(["/history"], navigationExtras);
  }

}
