-- Create a new database called 'BookHistory'
-- Connect to the 'master' database to run this snippet
USE master
GO
-- Create the new database if it does not exist already
IF NOT EXISTS (
    SELECT
    [name]
FROM
    sys.databases
WHERE [name] = N'BookHistory'
)
CREATE DATABASE BookHistory
GO

USE BookHistory
GO



DROP PROCEDURE IF EXISTS Book_Modify_tr;
DROP PROCEDURE IF EXISTS BookHistory_Search;
DROP PROCEDURE IF EXISTS BookHistory_Count;
GO

DROP TYPE IF EXISTS AuthorTableType; 
DROP TYPE IF EXISTS HistoryTypeTableType;
GO

DROP VIEW IF EXISTS BookHistoryTitle_V;
DROP VIEW IF EXISTS BookHistoryDescription_V;
DROP VIEW IF EXISTS BookHistoryPublishDate_V;
DROP VIEW IF EXISTS BookAuthorHistoryAdd_V;
DROP VIEW IF EXISTS BookAuthorHistoryDrop_V;
GO

DROP TABLE IF EXISTS BookAuthorHistory;
DROP TABLE IF EXISTS BookHistoryPublishDate;
DROP TABLE IF EXISTS BookHistoryDescription;
DROP TABLE IF EXISTS BookHistoryTitle;
DROP TABLE IF EXISTS BookHistory;
DROP TABLE IF EXISTS BookAuthor;
DROP TABLE IF EXISTS Author;
DROP TABLE IF EXISTS Book;
GO

-- #######################################################
-- ##                   Tables                          ##
-- #######################################################


CREATE TABLE Book
(
    BookId        INT           IDENTITY NOT NULL,
    -- -------------------------------------------
    Title         NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(256) NOT NULL,
    PublishDate   DATE          NOT NULL,
    UpdatedDtm    DATETIME      NOT NULL,
    -- -------------------------------------------
    CONSTRAINT UC_BookId 
        PRIMARY KEY CLUSTERED (BookId),
    CONSTRAINT Book_TitleIsNotBlank_ck 
        CHECK(Title <> N'')
);
GO


CREATE TABLE Author
(
    Author NVARCHAR(100) NOT NULL,
    -- ---------------------------
    CONSTRAINT UC_Author 
        PRIMARY KEY CLUSTERED (Author),
    CONSTRAINT Author_AuthorIsNotBlank_ck 
        CHECK(Author <> N'')
);
GO


CREATE TABLE BookAuthor
(
    BookId     INT           NOT NULL,
    Author     NVARCHAR(100) NOT NULL,
    -- -------------------------------
    IsObsolete BIT           NOT NULL,
    UpdatedDtm DATETIME      NOT NULL,
    -- -------------------------------
    CONSTRAINT UC_BookAuthor_pk 
        PRIMARY KEY CLUSTERED (BookId, Author),
    CONSTRAINT Book_IsWrittenBy_Author_fk 
        FOREIGN KEY (BookId)
        REFERENCES Book (BookId),
    CONSTRAINT Author_Writes_Book_fk 
        FOREIGN KEY (Author)
        REFERENCES Author (Author)
);
GO


CREATE TABLE BookHistory
(
    BookId     INT      NOT NULL,
    AuditedDtm DATETIME NOT NULL,
    -- ----------------------------------
    UpdatedDtm DATETIME NOT NULL,
    -- ----------------------------------
    CONSTRAINT UC_BookHistory_pk 
        PRIMARY KEY CLUSTERED (BookId, AuditedDtm),
    CONSTRAINT Book_Was_BookHistory_fk
        FOREIGN KEY (BookId)
        REFERENCES Book (BookId)
);
GO


CREATE TABLE BookHistoryTitle
(
    BookId     INT           NOT NULL,
    AuditedDtm DATETIME      NOT NULL,
    -- ----------------------------------
    Title      NVARCHAR(100) NOT NULL,
    -- ----------------------------------
    CONSTRAINT UC_BookHistoryTitle_pk 
        PRIMARY KEY CLUSTERED (BookId, AuditedDtm),
    CONSTRAINT BookHistory_Is_BookHistoryTitle_fk
        FOREIGN KEY (BookId, AuditedDtm)
        REFERENCES BookHistory (BookId, AuditedDtm)
);
GO


CREATE TABLE BookHistoryDescription
(
    BookId        INT           NOT NULL,
    AuditedDtm    DATETIME      NOT NULL,
    -- ----------------------------------
    [Description] NVARCHAR(256) NOT NULL,
    -- ----------------------------------
    CONSTRAINT UC_BookHistoryDescription_pk 
        PRIMARY KEY CLUSTERED (BookId, AuditedDtm),
    CONSTRAINT BookHistory_Is_BookHistoryDescription_fk
        FOREIGN KEY (BookId, AuditedDtm)
        REFERENCES BookHistory (BookId, AuditedDtm)
);
GO


CREATE TABLE BookHistoryPublishDate
(
    BookId      INT      NOT NULL,
    AuditedDtm  DATETIME NOT NULL,
    -- ----------------------------------
    PublishDate DATE     NOT NULL,
    -- ----------------------------------
    CONSTRAINT UC_BookHistoryPublishDate_pk 
        PRIMARY KEY CLUSTERED (BookId, AuditedDtm),
    CONSTRAINT BookHistory_Is_BookHistoryPublishDate_fk
        FOREIGN KEY (BookId, AuditedDtm)
        REFERENCES BookHistory (BookId, AuditedDtm)
);
GO


CREATE TABLE BookAuthorHistory
(
    BookId     INT           NOT NULL,
    Author     NVARCHAR(100) NOT NULL,
    AuditedDtm DATETIME      NOT NULL,
    -- -------------------------------
    IsObsolete BIT           NOT NULL,
    UpdatedDtm DATETIME      NOT NULL,
    -- -------------------------------
    CONSTRAINT UC_BookAuthorHistory_pk 
        PRIMARY KEY CLUSTERED (BookId, Author, AuditedDtm),
    CONSTRAINT BookAuthor_Was_BookAuthorHistory_fk 
        FOREIGN KEY (BookId, Author)
        REFERENCES BookAuthor (BookId, Author)
);
GO


-- #######################################################
-- ##                   Types                           ##
-- #######################################################

CREATE TYPE AuthorTableType 
    AS TABLE (
    Author NVARCHAR(100)
    );
GO

CREATE TYPE HistoryTypeTableType 
    AS TABLE (
    HistoryType INT
    );
GO



-- #######################################################
-- ##                   Views                           ##
-- #######################################################

-- Change Codes:
--  Title           : 1
--  Description     : 2
--  PublishDate     : 3
--  Author Add      : 4
--  Author Drop     : 5

CREATE OR ALTER VIEW BookHistoryTitle_V
AS
SELECT * FROM (
    SELECT  B.BookId, 
            ( SELECT MAX(AuditedDtm) FROM BookHistoryTitle WHERE B.BookId = BookId ) AS UpdatedDtm,  
            1 AS HistoryType, 
            B.Title AS Change
    FROM Book AS B
    UNION  
    SELECT  BHT.BookId, 
            ( SELECT MAX(AuditedDtm) FROM BookHistoryTitle WHERE BHT.BookId = BookId AND BHT.AuditedDtm > AuditedDtm ) AS UpdatedDtm, 
            1 AS HistoryType, 
            BHT.Title AS Change 
    FROM BookHistoryTitle AS BHT
    ) AS HT
WHERE HT.UpdatedDtm IS NOT NULL
GO


CREATE OR ALTER VIEW BookHistoryDescription_V
AS
SELECT * FROM (
    SELECT  B.BookId, 
            ( SELECT MAX(AuditedDtm) FROM BookHistoryDescription WHERE B.BookId = BookId ) AS UpdatedDtm,  
            2 AS HistoryType, 
            B.Description AS Change
    FROM Book AS B
    UNION  
    SELECT  BHD.BookId, 
            ( SELECT MAX(AuditedDtm) FROM BookHistoryDescription WHERE BHD.BookId = BookId AND BHD.AuditedDtm > AuditedDtm ) AS UpdatedDtm, 
            2 AS HistoryType, 
            BHD.Description AS Change 
    FROM BookHistoryDescription AS BHD
    ) AS HD
WHERE HD.UpdatedDtm IS NOT NULL
GO


CREATE OR ALTER VIEW BookHistoryPublishDate_V
AS
SELECT * FROM (
    SELECT  B.BookId, 
            ( SELECT MAX(AuditedDtm) FROM BookHistoryPublishDate WHERE B.BookId = BookId ) AS UpdatedDtm,  
            3 AS HistoryType, 
            CAST(B.PublishDate AS NVARCHAR) AS Change
    FROM Book AS B
    UNION  
    SELECT  BHPD.BookId, 
            ( SELECT MAX(AuditedDtm) FROM BookHistoryPublishDate WHERE BHPD.BookId = BookId AND BHPD.AuditedDtm > AuditedDtm ) AS UpdatedDtm, 
            3 AS HistoryType, 
            CAST(BHPD.PublishDate AS NVARCHAR) AS Change 
    FROM BookHistoryPublishDate AS BHPD
    ) AS HPD
WHERE HPD.UpdatedDtm IS NOT NULL
GO


CREATE OR ALTER VIEW BookAuthorHistoryAdd_V
AS
-- Not obsolete Authors added again after they have been removed
SELECT BookAuthor.BookId, BookAuthor.UpdatedDtm,  4 AS HistoryType, BookAuthor.Author AS Change
FROM BookAuthor INNER JOIN BookAuthorHistory ON BookAuthor.BookId = BookAuthorHistory.BookId AND BookAuthor.Author = BookAuthorHistory.Author AND BookAuthor.UpdatedDtm = BookAuthorHistory.AuditedDtm
WHERE BookAuthor.IsObsolete = 0
UNION  
-- Previous Author additions for Authors that are currently obsolete, excluding initial Authors
SELECT BookId, UpdatedDtm, 4 AS HistoryType, Author AS Change 
FROM BookAuthorHistory AS BAH 
WHERE IsObsolete = 0 
AND EXISTS (SELECT 1 FROM BookAuthorHistory WHERE BookId = BAH.BookId AND Author = BAH.Author AND AuditedDtm = BAH.UpdatedDtm AND IsObsolete = 1)
UNION
-- Authors added after initial insert, that have not been removed until now
SELECT BookId, UpdatedDtm, 4 AS HistoryType, Author AS Change 
FROM BookAuthor AS BA
WHERE IsObsolete = 0 
AND (
    UpdatedDtm > (SELECT UpdatedDtm FROM Book WHERE BookId = BA.BookId)
    OR
    UpdatedDtm > (SELECT MIN(UpdatedDtm) FROM BookHistory WHERE BookId = BA.BookId)
    )
GO


CREATE OR ALTER VIEW BookAuthorHistoryDrop_V
AS
SELECT BookId, UpdatedDtm,  5 AS HistoryType, Author AS Change
FROM BookAuthor WHERE IsObsolete = 1
UNION  
SELECT BookId, UpdatedDtm, 5 AS HistoryType, Author AS Change 
FROM BookAuthorHistory WHERE IsObsolete = 1
GO


-- #######################################################
-- ##                   API                             ##
-- #######################################################


CREATE OR ALTER PROCEDURE Book_Modify_tr
    @BookId INT,
    @NewTitle NVARCHAR(100),
    @NewDescription NVARCHAR(256),
    @NewPublishDate DATE,
    @NewAuthors AUTHORTABLETYPE READONLY
AS
SET NOCOUNT ON;
BEGIN TRANSACTION

DECLARE @Title NVARCHAR(100),
        @Description NVARCHAR(256),
        @PublishDate DATE,
        @UpdatedDtm DATETIME,
        @AuditedDtm DATETIME;

SET @AuditedDtm = CURRENT_TIMESTAMP;

-- Get current properties of Book with @BookId
SELECT  @Title = Title,
        @Description = [Description],
        @PublishDate = PublishDate,
        @UpdatedDtm = UpdatedDtm
FROM    Book
WHERE   BookId = @BookId;

-- If any of the properties is changed, create a BookHistory and a non-exclusive subtype record for each changed property
IF (@NewTitle <> @Title OR @NewDescription <> @Description OR @NewPublishDate <> @PublishDate)
    BEGIN

    INSERT INTO BookHistory
            (BookId, AuditedDtm, UpdatedDtm)
    VALUES  (@BookId, @AuditedDtm, @UpdatedDtm)

    IF (@NewTitle <> @Title)
        INSERT INTO BookHistoryTitle
                (BookId, AuditedDtm, Title)
        VALUES  (@BookId, @AuditedDtm, @Title);

    IF (@NewDescription <> @Description)
        INSERT INTO BookHistoryDescription
                (BookId, AuditedDtm, [Description])
        VALUES  (@BookId, @AuditedDtm, @Description);

    IF (@NewPublishDate <> @PublishDate)
        INSERT INTO BookHistoryPublishDate
                (BookId, AuditedDtm, PublishDate)
        VALUES  (@BookId, @AuditedDtm, @PublishDate);

    -- Lastly update Book
    -- TODO: Only update changed properties
    UPDATE Book
    SET Title = @NewTitle,
        [Description] = @NewDescription,
        PublishDate = @NewPublishDate,
        UpdatedDtm = @AuditedDtm
    WHERE 
        BookId = @BookId;

END

-- Insert new Authors
INSERT INTO Author 
        (Author)
SELECT  Author
FROM    @NewAuthors
WHERE   Author NOT IN ( SELECT Author FROM Author );

-- Insert new BookAuthors
INSERT INTO BookAuthor 
        (BookId, Author, IsObsolete, UpdatedDtm)
SELECT  @BookId, Author, 0, @AuditedDtm
FROM    @NewAuthors
WHERE   Author NOT IN ( SELECT Author FROM BookAuthor WHERE BookId=@BookId );

-- Insert new BookAuthorHistory
INSERT INTO BookAuthorHistory 
        (BookId, Author, AuditedDtm, IsObsolete, UpdatedDtm)
SELECT 
        BookId, Author, @AuditedDtm, IsObsolete, UpdatedDtm
FROM    BookAuthor
WHERE   BookId = @BookId 
AND ( 
        (Author IN (SELECT * FROM @NewAuthors) AND IsObsolete = 1)
        OR
        (Author NOT IN (SELECT * FROM @NewAuthors) AND IsObsolete = 0)
    )

-- Restore BookAuthors
UPDATE  BookAuthor
SET     IsObsolete=0,
        UpdatedDtm = @AuditedDtm
WHERE   BookId=@BookId
AND     Author IN ( SELECT Author FROM @NewAuthors)
AND     IsObsolete = 1;

--Soft-delete BookAuthors
UPDATE  BookAuthor
SET     IsObsolete=1,
        UpdatedDtm = @AuditedDtm
WHERE   BookId=@BookId
AND     Author NOT IN ( SELECT Author FROM @NewAuthors)
AND     IsObsolete = 0;

COMMIT
GO


CREATE OR ALTER PROCEDURE BookHistory_Search
    @BookId         INT                             = NULL,     -- Get changes for this book only
    @FromDtm        DATETIME                        = NULL,     -- Get changes made on @FromDtm or later
    @ToDtm          DATETIME                        = NULL,     -- Get changes made on @ToDtm or earlier
    @HistoryTypes   HistoryTypeTableType READONLY,              -- Get changes of the specified types, or any type if empty
    @PageNo         INT                             = NULL,
    @PageSize       INT                             = NULL,
    @Order          NVARCHAR(4)                     = 'DESC'    -- Ascending ('ASC') or Descending ('DESC') order by UpdatedDtm
AS

SELECT * FROM (
    SELECT * FROM BookHistoryTitle_V 
    UNION
    SELECT * FROM BookHistoryDescription_V 
    UNION
    SELECT * FROM BookHistoryPublishDate_V
    UNION
    SELECT * FROM BookAuthorHistoryAdd_V
    UNION
    SELECT * FROM BookAuthorHistoryDrop_V
) AS History
WHERE   (History.BookId = @BookId OR @BookId IS NULL)
AND     (History.UpdatedDtm >= @FromDtm OR @FromDtm IS NULL)
AND     (History.UpdatedDtm <= @ToDtm OR @ToDtm IS NULL)
AND     (History.HistoryType IN (SELECT HistoryType FROM @HistoryTypes) OR NOT EXISTS (SELECT 1 FROM @HistoryTypes))
ORDER BY    CASE WHEN @Order = 'DESC' OR @Order IS NULL THEN History.UpdatedDtm END DESC, 
            CASE WHEN @Order='ASC' THEN History.UpdatedDtm END ASC
OFFSET      CASE WHEN @PageNo >= 0 AND @PageSize > 0 THEN @PageSize * @PageNo ELSE 0 END ROWS
FETCH NEXT  CASE WHEN @PageSize > 0 THEN @PageSize ELSE 100 END ROWS ONLY
OPTION (RECOMPILE)
GO


-- https://www.sqlservercentral.com/articles/optimising-server-side-paging-part-ii
CREATE OR ALTER PROCEDURE BookHistory_Count
    @BookId         INT                             = NULL,     -- Get changes for this book only
    @FromDtm        DATETIME                        = NULL,     -- Get changes made on @FromDtm or later
    @ToDtm          DATETIME                        = NULL,     -- Get changes made on @ToDtm or earlier
    @HistoryTypes   HistoryTypeTableType READONLY               -- Get changes of the specified types, or any type if empty
AS

SELECT Count(*) FROM (
    SELECT * FROM BookHistoryTitle_V 
    UNION
    SELECT * FROM BookHistoryDescription_V 
    UNION
    SELECT * FROM BookHistoryPublishDate_V
    UNION
    SELECT * FROM BookAuthorHistoryAdd_V
    UNION
    SELECT * FROM BookAuthorHistoryDrop_V
) AS History
WHERE   (History.BookId = @BookId OR @BookId IS NULL)
AND     (History.UpdatedDtm >= @FromDtm OR @FromDtm IS NULL)
AND     (History.UpdatedDtm <= @ToDtm OR @ToDtm IS NULL)
AND     (History.HistoryType IN (SELECT HistoryType FROM @HistoryTypes) OR NOT EXISTS (SELECT 1 FROM @HistoryTypes))
OPTION (RECOMPILE)
GO


-- #######################################################
-- ##                   Roles & Users                   ##
-- #######################################################

DROP USER IF EXISTS BookHistoryWebClient;
DROP ROLE IF EXISTS BookHistoryRole;
DROP LOGIN BookHistoryWebClient;
GO

CREATE ROLE BookHistoryRole;
GRANT EXECUTE ON Book_Modify_tr TO BookHistoryRole;
GRANT EXECUTE ON BookHistory_Search TO BookHistoryRole;
GRANT EXECUTE ON BookHistory_Count TO BookHistoryRole;
GRANT SELECT ON SCHEMA::dbo TO BookHistoryRole;
GRANT EXECUTE ON TYPE::AuthorTableType TO BookHistoryRole;
GRANT EXECUTE ON TYPE::HistoryTypeTableType TO BookHistoryRole;
GO 

CREATE LOGIN BookHistoryWebClient WITH PASSWORD = 'testpassword';
CREATE USER BookHistoryWebClient FOR LOGIN BookHistoryWebClient;
ALTER ROLE BookHistoryRole ADD MEMBER BookHistoryWebClient;
GO



-- #######################################################
-- ##                   Seeds                           ##
-- #######################################################

DECLARE @CreatedDtm DATETIME = CURRENT_TIMESTAMP;

INSERT INTO Author
    (Author)
VALUES
    ('Suzanne Collins'),
    ('J.K. Rowling'),
    ('Stephenie Meyer'),
    ('Harper Lee'),
    ('F. Scott Fitzgerald'),
    ('John Green'),
    ('J.R.R. Tolkien'),
    ('J.D. Salinger'),
    ('Dan Brown'),
    ('Jane Austen'),
    ('Khaled Hosseini'),
    ('Veronica Roth'),
    ('Erich Fromm'),
    ('Celâl Üster'),
    ('George Orwell'),
    ('Anne Frank'),
    ('Eleanor Roosevelt'),
    ('B.M. Mooyaart-Doubleday'),
    ('Stieg Larsson'),
    ('Reg Keeland'),
    ('Rufus Beck'),
    ('Mary GrandPré');

INSERT INTO Book
VALUES
    ('The Hunger Games', '...', CONVERT(DATE,'2008'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Suzanne Collins', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('Harry Potter and the Philosopher''s Stone', '...', CONVERT(DATE,'1997'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'J.K. Rowling', 0, @CreatedDtm),
    (@@IDENTITY, 'Mary GrandPré', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('Twilight', '...', CONVERT(DATE,'2005'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Stephenie Meyer', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('To Kill a Mockingbird', '...', CONVERT(DATE,'1960'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Harper Lee', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('The Great Gatsby', '...', CONVERT(DATE,'1925'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'F. Scott Fitzgerald', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('The Fault in Our Stars', '...', CONVERT(DATE,'2012'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'John Green', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('The Hobbit or There and Back Again', '...', CONVERT(DATE,'1937'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'J.R.R. Tolkien', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('The Catcher in the Rye', '...', CONVERT(DATE,'1951'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'J.D. Salinger', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('Angels & Demons', '...', CONVERT(DATE,'2000'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Dan Brown', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('Pride and Prejudice', '...', CONVERT(DATE,'1813'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Jane Austen', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('The Kite Runner', '...', CONVERT(DATE,'2003'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Khaled Hosseini', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('Divergent', '...', CONVERT(DATE,'2011'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Veronica Roth', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('Nineteen Eighty-Four', '...', CONVERT(DATE,'1949'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'George Orwell', 0, @CreatedDtm),
    (@@IDENTITY, 'Erich Fromm', 0, @CreatedDtm),
    (@@IDENTITY, 'Celâl Üster', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('Animal Farm: A Fairy Story', '...', CONVERT(DATE,'1945'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'George Orwell', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('Het Achterhuis: Dagboekbrieven 14 juni 1942 - 1 augustus 1944', '...', CONVERT(DATE,'1947'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Anne Frank', 0, @CreatedDtm),
    (@@IDENTITY, 'Eleanor Roosevelt', 0, @CreatedDtm),
    (@@IDENTITY, 'B.M. Mooyaart-Doubleday', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('Män som hatar kvinnor', '...', CONVERT(DATE,'2005'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Stieg Larsson', 0, @CreatedDtm),
    (@@IDENTITY, 'Reg Keeland', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('Catching Fire', '...', CONVERT(DATE,'2009'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Suzanne Collins', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('Harry Potter and the Prisoner of Azkaban', '...', CONVERT(DATE,'1999'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'J.K. Rowling', 0, @CreatedDtm),
    (@@IDENTITY, 'Mary GrandPré', 0, @CreatedDtm),
    (@@IDENTITY, 'Rufus Beck', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('The Fellowship of the Ring', '...', CONVERT(DATE,'1954'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'J.R.R. Tolkien', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('Mockingjay', '...', CONVERT(DATE,'2010'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Suzanne Collins', 0, @CreatedDtm);

INSERT INTO Book
VALUES
    ('Harry Potter and the Order of the Phoenix', '...', CONVERT(DATE,'2003'), @CreatedDtm);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'J.K. Rowling', 0, @CreatedDtm),
    (@@IDENTITY, 'Mary GrandPré', 0, @CreatedDtm);




