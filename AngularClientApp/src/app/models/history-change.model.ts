export enum HistoryType {
    Title = 1,
    Description = 2,
    PublishDate = 3,
    AuthorAdd = 4,
    AuthorDrop = 5
}

export interface HistoryChange {
    bookId: number;
    updatedDtm: Date;
    historyType: HistoryType;
    change: string;
}