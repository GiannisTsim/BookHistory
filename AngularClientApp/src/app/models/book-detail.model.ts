import { Book } from "./book.model";

export interface BookDetail extends Book {
    description: string;
    updatedDtm: Date;
    authors: string[];
}