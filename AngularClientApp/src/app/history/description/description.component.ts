import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from "@angular/router";

import { HistoryQueryParam } from "src/app/models/history-query-param.enum";

import { RecordType } from "src/app/models/record-type.enum";

@Component({
  selector: 'app-description',
  templateUrl: './description.component.html',
  styleUrls: ['./description.component.css']
})
export class DescriptionComponent implements OnInit {

  bookId: number;
  recordTypes: string[];
  fromDtm: string;
  toDtm: string;

  recordTypeDescription: { [key: string]: { icon: string, text: string; }; } = {
    [RecordType.Title]: { icon: "short_text", text: "Title" },
    [RecordType.Description]: { icon: "short_text", text: "Description" },
    [RecordType.PublishDate]: { icon: "short_text", text: "Publish date" },
    [RecordType.AuthorAdd]: { icon: "add", text: "Author" },
    [RecordType.AuthorDrop]: { icon: "remove", text: "Author" },
  };

  constructor(private route: ActivatedRoute) { }

  ngOnInit(): void {
    this.route.queryParamMap
      .subscribe(paramMap => {
        this.bookId = parseInt(paramMap.get(HistoryQueryParam.BookId), 10);
        this.recordTypes = paramMap.getAll(HistoryQueryParam.RecordTypes);
        this.fromDtm = paramMap.get(HistoryQueryParam.FromDtm);
        this.toDtm = paramMap.get(HistoryQueryParam.ToDtm);
      });
  }

}
