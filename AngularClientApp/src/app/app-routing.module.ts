import { NgModule } from "@angular/core";
import { Routes, RouterModule } from "@angular/router";

import { BooksComponent } from "./books/books.component";
import { BookDetailComponent } from "./books/book-detail/book-detail.component";
import { HistoryComponent } from "./history/history.component";
import { PageNotFoundComponent } from "./page-not-found/page-not-found.component";

const routes: Routes = [
  { path: "", redirectTo: "/books", pathMatch: "full" },
  {
    path: "books", component: BooksComponent, children: [
      { path: ":bookId", component: BookDetailComponent }
    ]
  },
  { path: "history", component: HistoryComponent },
  { path: "**", component: PageNotFoundComponent },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
})
export class AppRoutingModule { }
