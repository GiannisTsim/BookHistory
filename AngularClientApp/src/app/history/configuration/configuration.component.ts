import { Component, OnInit } from '@angular/core';
import { FormControl, FormGroup } from "@angular/forms";
import { NavigationExtras, Router } from "@angular/router";
import { isEmpty } from "lodash-es";

import { RecordType } from "src/app/models/record-type.enum";

@Component({
  selector: 'app-configuration',
  templateUrl: './configuration.component.html',
  styleUrls: ['./configuration.component.css']
})
export class ConfigurationComponent implements OnInit {
  recordType = RecordType;

  configForm = new FormGroup({
    shouldFilterByRecordType: new FormControl(false),
    recordTypes: new FormControl([]),
    shouldFilterByDtm: new FormControl(false),
    toDtm: new FormControl(''),
    fromDtm: new FormControl(''),
  });

  constructor(private router: Router) { }

  get recordTypes() {
    return this.configForm.get("recordTypes");
  }

  get shouldFilterByRecordType() {
    return this.configForm.get("shouldFilterByRecordType");
  }

  get fromDtm() {
    return this.configForm.get("fromDtm");
  }

  get toDtm() {
    return this.configForm.get("toDtm");
  }

  get shouldFilterByDtm() {
    return this.configForm.get("shouldFilterByDtm");
  }

  ngOnInit(): void { }

  onSearch() {

    // Setting a query param to null, will remove the param if it exists
    const navigationExtras: NavigationExtras = {
      queryParamsHandling: 'merge',
      queryParams: {
        recordTypes: null,
        fromDtm: null,
        toDtm: null,
        pageNo: 0
      }
    };

    // Refresh route with updated query parameters based on configuration form
    if (this.shouldFilterByRecordType.value && !isEmpty(this.recordTypes.value)) {
      navigationExtras.queryParams.recordTypes = this.recordTypes.value;
    }
    if (this.shouldFilterByDtm.value) {
      if (!isEmpty(this.fromDtm.value)) {
        navigationExtras.queryParams.fromDtm = this.fromDtm.value;
      }
      if (!isEmpty(this.toDtm.value)) {
        navigationExtras.queryParams.toDtm = this.toDtm.value;
      }
    }
    this.router.navigate(["/history"], navigationExtras);

    // Reset filters but leave filter panels open
    this.recordTypes.reset();
    this.fromDtm.reset();
    this.toDtm.reset();
  }

}
