export enum RecordType {
    Title = 1,
    Description = 2,
    PublishDate = 3,
    AuthorAdd = 4,
    AuthorDrop = 5
}

export interface HistoryRecord {
    bookId: number;
    recordType: RecordType;
    change: string;
    updatedDtm: Date;
}