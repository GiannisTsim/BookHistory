import { RecordType } from "./record-type.enum";

export interface HistoryRecord {
    bookId: number;
    updatedDtm: Date;
    recordType: RecordType;
    change: string;
}