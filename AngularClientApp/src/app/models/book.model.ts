export interface Book {
    bookId: number;
    title: string;
    publishDate: Date;
}

export interface BookDetail {
    bookId: number;
    title: string;
    description: string;
    publishDate: Date;
    updatedDtm: Date;
    authors: string[];
}