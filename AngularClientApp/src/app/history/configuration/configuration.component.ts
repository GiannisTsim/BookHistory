import { Component, OnInit } from '@angular/core';

import { HistoryType } from "src/app/models/history-change.model";

@Component({
  selector: 'app-configuration',
  templateUrl: './configuration.component.html',
  styleUrls: ['./configuration.component.css']
})
export class ConfigurationComponent implements OnInit {
  // searchConfig = new FormGroup({
  //   bookId: new FormControl(""),
  //   fromDtm: new FormControl(""),
  //   toDtm: new FormControl(""),
  //   historyTypes: new FormControl([]),
  //   order: new FormControl("")
  // })

  historyType = HistoryType;

  // historyTypeSelection = new SelectionModel<HistoryType>(true, []);
  constructor() { }

  ngOnInit(): void {
  }

}
