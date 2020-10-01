import { HistoryRecord } from "./history-record.model";

export interface HistorySearchResult {
    totalCount: number;
    historyRecords: HistoryRecord[];
}