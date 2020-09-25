-- Create a new database called 'BookHistory'
-- Connect to the 'master' database to run this snippet
USE master
GO
-- DROP DATABASE IF EXISTS BookHistory
-- GO
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


-- #######################################################
-- ##                   Tables                          ##
-- #######################################################

DROP TABLE IF EXISTS BookAuthorHistory;
DROP TABLE IF EXISTS BookHistoryPublishDate;
DROP TABLE IF EXISTS BookHistoryDescription;
DROP TABLE IF EXISTS BookHistoryTitle;
DROP TABLE IF EXISTS BookHistory;
DROP TABLE IF EXISTS BookAuthor;
DROP TABLE IF EXISTS Author;
DROP TABLE IF EXISTS Book;
GO

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
-- ##                   API                             ##
-- #######################################################

DROP PROCEDURE IF EXISTS Book_Add_tr;
GO
CREATE PROCEDURE Book_Add_tr
    @Title NVARCHAR(100),
    @Description NVARCHAR(256),
    @PublishDate DATE
AS
SET NOCOUNT ON;
BEGIN TRANSACTION

INSERT INTO Book
VALUES
    (@Title, @Description, @PublishDate, CURRENT_TIMESTAMP);

COMMIT
GO

DROP PROCEDURE IF EXISTS Book_Modify_tr;
GO
CREATE PROCEDURE Book_Modify_tr
    @BookId INT,
    @NewTitle NVARCHAR(100),
    @NewDescription NVARCHAR(256),
    @NewPublishDate DATE
AS
SET NOCOUNT ON;
BEGIN TRANSACTION

-- TODO

COMMIT
GO


DROP PROCEDURE IF EXISTS BookAuthor_Add_tr;
GO
CREATE PROCEDURE BookAuthor_Add_tr
    @BookId INT,
    @Author NVARCHAR(100)
AS
SET NOCOUNT ON;
BEGIN TRANSACTION

-- TODO

COMMIT
GO

DROP PROCEDURE IF EXISTS BookAuthor_Drop_tr;
GO
CREATE PROCEDURE BookAuthor_Drop_tr
    @BookId INT,
    @Author NVARCHAR(100)
AS
SET NOCOUNT ON;
BEGIN TRANSACTION

-- TODO

COMMIT
GO


-- #######################################################
-- ##                   Views                           ##
-- #######################################################



-- #######################################################
-- ##                   Seeds                           ##
-- #######################################################

