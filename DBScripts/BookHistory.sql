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
GO
DROP PROCEDURE IF EXISTS BookAuthor_Add_tr;
GO
DROP PROCEDURE IF EXISTS BookAuthor_Drop_tr;
GO
DROP TYPE IF EXISTS AuthorTableType 
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
SELECT
    @Title = Title,
    @Description = [Description],
    @PublishDate = PublishDate,
    @UpdatedDtm = UpdatedDtm
FROM
    Book
WHERE
    BookId = @BookId;

-- If any of the properties is changed, create a BookHistory and a non-exclusive subtype record for each changed property
IF (@NewTitle <> @Title OR @NewDescription <> @Description OR @NewPublishDate <> @PublishDate)
    BEGIN

    INSERT INTO BookHistory
        (BookId, AuditedDtm, UpdatedDtm)
    VALUES
        (@BookId, @AuditedDtm, @UpdatedDtm)

    IF (@NewTitle <> @Title)
    INSERT INTO BookHistoryTitle
        (BookId, AuditedDtm, Title)
    VALUES
        (@BookId, @AuditedDtm, @Title);

    IF (@NewDescription <> @Description)
    INSERT INTO BookHistoryDescription
        (BookId, AuditedDtm, [Description])
    VALUES
        (@BookId, @AuditedDtm, @Description);

    IF (@NewPublishDate <> @PublishDate)
    INSERT INTO BookHistoryPublishDate
        (BookId, AuditedDtm, PublishDate)
    VALUES
        (@BookId, @AuditedDtm, @PublishDate);

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
SELECT
    Author
FROM
    @NewAuthors
WHERE 
    Author NOT IN (
    SELECT
    Author
FROM
    Author
    );

-- Insert new BookAuthors
INSERT INTO BookAuthor
    (BookId, Author, IsObsolete, UpdatedDtm)
SELECT
    @BookId,
    Author,
    0,
    @AuditedDtm
FROM
    @NewAuthors
WHERE
    Author NOT IN (
        SELECT
    Author
FROM
    BookAuthor
WHERE BookId=@BookId
    );

-- Insert new BookHistory
INSERT INTO BookAuthorHistory
    (BookId, Author, AuditedDtm, IsObsolete, UpdatedDtm)
SELECT
    BookId,
    Author,
    @AuditedDtm,
    IsObsolete,
    UpdatedDtm
FROM
    BookAuthor
WHERE 
        BookId = @BookId AND
    ((Author IN (SELECT
        *
    FROM
        @NewAuthors) AND IsObsolete = 1)
    OR
    (Author NOT IN (SELECT
        *
    FROM
        @NewAuthors) AND IsObsolete = 0))

-- Restore BookAuthors
UPDATE BookAuthor
    SET IsObsolete=0,
        UpdatedDtm = @AuditedDtm
    WHERE BookId=@BookId
    AND Author IN (
        SELECT
        Author
    FROM
        @NewAuthors)
    AND IsObsolete = 1;

--Soft-delete BookAuthors
UPDATE BookAuthor
    SET IsObsolete=1,
        UpdatedDtm = @AuditedDtm
    WHERE BookId=@BookId
    AND Author NOT IN (
        SELECT
        Author
    FROM
        @NewAuthors)
    AND IsObsolete = 0;

COMMIT
GO


CREATE PROCEDURE BookAuthor_Add_tr
    @BookId INT,
    @Author NVARCHAR(100)
AS
SET NOCOUNT ON;
BEGIN TRANSACTION

-- If BookAuthor with @BookId and @Author already exists, check @IsObsolete flag and update accordingly
IF EXISTS ( 
SELECT
    1
FROM
    BookAuthor
WHERE 
    BookId = @BookId AND Author = @Author
)
BEGIN

    DECLARE @IsObsolete BIT,
            @UpdatedDtm DATETIME;

    SELECT
        @IsObsolete = IsObsolete,
        @UpdatedDtm = UpdatedDtm
    FROM
        BookAuthor
    WHERE 
        BookId = @BookId AND Author = @Author

    -- If the record was flagged with @IsObsolete = true (it was previously soft-deleted), append the change in BookAuthorHistory and update BookAuthor
    -- Else no action is required
    IF @IsObsolete = 1
    BEGIN
        DECLARE @AuditedDtm DATETIME;
        SET @AuditedDtm = CURRENT_TIMESTAMP;

        INSERT INTO BookAuthorHistory
            (BookId, Author, AuditedDtm, IsObsolete, UpdatedDtm)
        VALUES
            (@BookId, @Author, @AuditedDtm, 1, @UpdatedDtm);

        UPDATE BookAuthor
        SET IsObsolete = 0,
            UpdatedDtm = @AuditedDtm
        WHERE
            BookId = @BookId AND Author = @Author
    END
END
-- If a record in BookAuthor with @BookId and @Author does not exist, insert a new one
ELSE
BEGIN
    INSERT INTO BookAuthor
        (BookId, Author, IsObsolete, UpdatedDtm)
    VALUES
        (@BookId, @Author, 0, CURRENT_TIMESTAMP);
END

COMMIT
GO


CREATE PROCEDURE BookAuthor_Drop_tr
    @BookId INT,
    @Author NVARCHAR(100)
AS
SET NOCOUNT ON;
BEGIN TRANSACTION

-- If BookAuthor with @BookId and @Author already exists, check @IsObsolete flag and update accordingly
IF EXISTS ( 
SELECT
    1
FROM
    BookAuthor
WHERE 
    BookId = @BookId AND Author = @Author
)
BEGIN

    DECLARE @IsObsolete BIT,
            @UpdatedDtm DATETIME;

    SELECT
        @IsObsolete = IsObsolete,
        @UpdatedDtm = UpdatedDtm
    FROM
        BookAuthor
    WHERE 
        BookId = @BookId AND Author = @Author

    -- If the record was flagged with @IsObsolete = false, append the change in BookAuthorHistory and soft-delete BookAuthor
    -- Else no action is required
    IF @IsObsolete = 0
    BEGIN
        DECLARE @AuditedDtm DATETIME;
        SET @AuditedDtm = CURRENT_TIMESTAMP;

        INSERT INTO BookAuthorHistory
            (BookId, Author, AuditedDtm, IsObsolete, UpdatedDtm)
        VALUES
            (@BookId, @Author, @AuditedDtm, 0, @UpdatedDtm);

        UPDATE BookAuthor
        SET IsObsolete = 1,
            UpdatedDtm = @AuditedDtm
        WHERE
            BookId = @BookId AND Author = @Author
    END
END
-- If a record in BookAuthor with @BookId and @Author does not exist, return NOT FOUND error code
ELSE
BEGIN
    SELECT
        1;
-- TODO: Throw NOT FOUND 
END

COMMIT
GO


-- #######################################################
-- ##                   Views                           ##
-- #######################################################


-- #######################################################
-- ##                   Roles & Users                   ##
-- #######################################################

DROP USER IF EXISTS BookHistoryWebClient;
DROP ROLE IF EXISTS BookHistoryRole;
DROP LOGIN BookHistoryWebClient;

CREATE ROLE BookHistoryRole;
GRANT EXECUTE ON Book_Modify_tr TO BookHistoryRole;
GRANT EXECUTE ON BookAuthor_Add_tr TO BookHistoryRole;
GRANT EXECUTE ON BookAuthor_Drop_tr TO BookHistoryRole;
GRANT SELECT ON SCHEMA::dbo TO BookHistoryRole;
GRANT EXECUTE ON TYPE::AuthorTableType TO BookHistoryRole;

CREATE LOGIN BookHistoryWebClient WITH PASSWORD = 'testpassword';
CREATE USER BookHistoryWebClient FOR LOGIN BookHistoryWebClient;
ALTER ROLE BookHistoryRole ADD MEMBER BookHistoryWebClient;


-- #######################################################
-- ##                   Seeds                           ##
-- #######################################################

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
    ('The Hunger Games', '...', CONVERT(DATE,'2008'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Suzanne Collins', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('Harry Potter and the Philosopher''s Stone', '...', CONVERT(DATE,'1997'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'J.K. Rowling', 0, CURRENT_TIMESTAMP),
    (@@IDENTITY, 'Mary GrandPré', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('Twilight', '...', CONVERT(DATE,'2005'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Stephenie Meyer', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('To Kill a Mockingbird', '...', CONVERT(DATE,'1960'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Harper Lee', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('The Great Gatsby', '...', CONVERT(DATE,'1925'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'F. Scott Fitzgerald', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('The Fault in Our Stars', '...', CONVERT(DATE,'2012'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'John Green', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('The Hobbit or There and Back Again', '...', CONVERT(DATE,'1937'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'J.R.R. Tolkien', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('The Catcher in the Rye', '...', CONVERT(DATE,'1951'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'J.D. Salinger', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('Angels & Demons', '...', CONVERT(DATE,'2000'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Dan Brown', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('Pride and Prejudice', '...', CONVERT(DATE,'1813'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Jane Austen', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('The Kite Runner', '...', CONVERT(DATE,'2003'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Khaled Hosseini', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('Divergent', '...', CONVERT(DATE,'2011'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Veronica Roth', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('Nineteen Eighty-Four', '...', CONVERT(DATE,'1949'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'George Orwell', 0, CURRENT_TIMESTAMP),
    (@@IDENTITY, 'Erich Fromm', 0, CURRENT_TIMESTAMP),
    (@@IDENTITY, 'Celâl Üster', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('Animal Farm: A Fairy Story', '...', CONVERT(DATE,'1945'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'George Orwell', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('Het Achterhuis: Dagboekbrieven 14 juni 1942 - 1 augustus 1944', '...', CONVERT(DATE,'1947'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Anne Frank', 0, CURRENT_TIMESTAMP),
    (@@IDENTITY, 'Eleanor Roosevelt', 0, CURRENT_TIMESTAMP),
    (@@IDENTITY, 'B.M. Mooyaart-Doubleday', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('Män som hatar kvinnor', '...', CONVERT(DATE,'2005'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Stieg Larsson', 0, CURRENT_TIMESTAMP),
    (@@IDENTITY, 'Reg Keeland', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('Catching Fire', '...', CONVERT(DATE,'2009'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Suzanne Collins', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('Harry Potter and the Prisoner of Azkaban', '...', CONVERT(DATE,'1999'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'J.K. Rowling', 0, CURRENT_TIMESTAMP),
    (@@IDENTITY, 'Mary GrandPré', 0, CURRENT_TIMESTAMP),
    (@@IDENTITY, 'Rufus Beck', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('The Fellowship of the Ring', '...', CONVERT(DATE,'1954'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'J.R.R. Tolkien', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('Mockingjay', '...', CONVERT(DATE,'2010'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'Suzanne Collins', 0, CURRENT_TIMESTAMP);

INSERT INTO Book
VALUES
    ('Harry Potter and the Order of the Phoenix', '...', CONVERT(DATE,'2003'), CURRENT_TIMESTAMP);
INSERT INTO BookAuthor
VALUES
    (@@IDENTITY, 'J.K. Rowling', 0, CURRENT_TIMESTAMP),
    (@@IDENTITY, 'Mary GrandPré', 0, CURRENT_TIMESTAMP);




