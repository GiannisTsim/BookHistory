import { HistoryType } from "./history-change.model";

export enum Order {
    Asc = "ASC",
    Desc = "DESC"
}

export interface HistoryQueryParams {
    bookId?: number,
    fromDtm?: Date,
    toDtm?: Date,
    historyTypes?: HistoryType[];
    pageNo?: number,
    pageSize?: number,
    order?: Order;
}