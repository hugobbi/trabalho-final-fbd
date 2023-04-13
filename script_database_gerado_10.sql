-- Matheus Henrique Sabadin – 00228729
-- Henrique Uhlmann Gobbi – 00334932


-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE Language (
	LangCode uuid PRIMARY KEY,
    LangLabel varchar(80) NOT NULL
);

CREATE TABLE Publisher (
	PubCode uuid PRIMARY KEY,
    PubLabel varchar(80) NOT NULL
);

CREATE TABLE Country (
    CtryCode uuid PRIMARY KEY,
	CtryLabel varchar(80) NOT NULL
);

CREATE TABLE Author (
    AuthorCode uuid PRIMARY KEY,
	AuthorLabel varchar(500) NOT NULL
);

CREATE TABLE Gender (
	GendCode uuid PRIMARY KEY,
    GendLabel varchar(80) NOT NULL
);

CREATE TABLE Book (
    ISBN13 bigint PRIMARY KEY NOT NULL,
    Title varchar(500) NOT NULL,
    PageCount smallint NOT NULL,
    RatingCount int NOT NULL,
    ReviewCount int NOT NULL,
    PublishingDate date NOT NULL,
    CtryCode uuid NOT NULL,
    PubCode uuid NOT NULL,
    LangCode uuid NOT NULL,
	FOREIGN KEY (CtryCode) REFERENCES Country(CtryCode) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (PubCode) REFERENCES Publisher(PubCode) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (LangCode) REFERENCES Language(LangCode) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE GoodreadsUser (
    UserCode uuid PRIMARY KEY,
    UserName varchar(80) NOT NULL,
    Age smallint,
    Sex char,
    Email varchar(80) NOT NULL
);

CREATE TABLE Follows (
    FlwCode uuid PRIMARY KEY,
	UserACode uuid NOT NULL,
	UserBCode uuid NOT NULL
);

CREATE TABLE Rating (
    RtgCode uuid PRIMARY KEY,
    NumberOfStars smallint NOT NULL,
	UserCode uuid NOT NULL,
	ISBN13 bigint NOT NULL,
	FOREIGN KEY (UserCode) REFERENCES GoodreadsUser(UserCode) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (ISBN13) REFERENCES Book(ISBN13) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Review (
    RvwCode uuid PRIMARY KEY,
    Text text NOT NULL,
    UserCode uuid NOT NULL,
	ISBN13 bigint NOT NULL,
	FOREIGN KEY (UserCode) REFERENCES GoodreadsUser(UserCode) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (ISBN13) REFERENCES Book(ISBN13) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE HasGender (
	HasGendCode uuid,
    ISBN13 bigint NOT NULL,
    GendCode uuid NOT NULL,
	FOREIGN KEY (ISBN13) REFERENCES Book(ISBN13) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (GendCode) REFERENCES Gender(GendCode) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE WrittenBy (
	WrittenByCode uuid,
	ISBN13 bigint NOT NULL,
    AuthorCode uuid NOT NULL,
	FOREIGN KEY (ISBN13) REFERENCES Book(ISBN13) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (AuthorCode) REFERENCES Author(AuthorCode) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE BookshelfBook (
    BookshelfBookCode uuid PRIMARY KEY,
    BookStatus varchar(20) NOT NULL,
	UserCode uuid NOT NULL,
	ISBN13 bigint NOT NULL,
	FOREIGN KEY (UserCode) REFERENCES GoodreadsUser(UserCode) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (ISBN13) REFERENCES Book(ISBN13) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION increment_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE book SET ratingcount = ratingcount + 1 WHERE book.isbn13 = NEW.isbn13;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rating_counter
AFTER INSERT ON Rating
FOR EACH ROW
EXECUTE PROCEDURE increment_rating();

CREATE OR REPLACE FUNCTION increment_review()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE book SET reviewcount = reviewcount + 1 WHERE book.isbn13 = NEW.isbn13;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER review_counter
AFTER INSERT ON Review
FOR EACH ROW
EXECUTE PROCEDURE increment_review();

-- Visão contendo um livro e seu autor
CREATE VIEW book_author AS
SELECT book.isbn13, author.authorlabel
FROM book NATURAL JOIN writtenby NATURAL JOIN author;

-- Visão contendo informações sobre o livro e a média de estrelas dele
CREATE VIEW book_avg_rating AS
SELECT book.isbn13, book.title, book.ctrycode, book.langcode, book.pubcode, book.ratingcount, AVG(rating.numberofstars) AS avg_rating
FROM book NATURAL JOIN rating
GROUP BY book.isbn13, book.title, book.ctrycode, book.langcode, book.pubcode, book.ratingcount;

-- Visão contendo usuário e número de pessoas seguindo e que seguem ele
CREATE VIEW user_follows AS
SELECT usercode, seguindo, seguidores
FROM (SELECT usercode, COUNT(userbcode) AS seguidores
      FROM goodreadsuser LEFT JOIN follows ON usercode = userbcode
      GROUP BY usercode, userbcode) AS seguidores_tab
      JOIN
      (SELECT usercode, COUNT(useracode) AS seguindo
      FROM goodreadsuser LEFT JOIN follows ON usercode = useracode
      GROUP BY usercode, useracode) AS seguindo_tab
      USING(usercode);

-- PROCEDIMENTOS ARMAZENADOS --

-- Verifica se o usuário que quer inserir uma avaliação para um livro já leu esse livro
CREATE OR REPLACE FUNCTION check_leu_livro() RETURNS TRIGGER AS $$
BEGIN
    IF (select bookstatus from bookshelfbook where usercode = NEW.usercode and isbn13 = NEW.isbn13) <> 'Read' THEN
        RAISE EXCEPTION 'O usuário tem que ter lido o livro para poder avaliá-lo';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Verifica se usuário já leu o livro para inserir um rating nele
CREATE TRIGGER rating_livro_lido
BEFORE INSERT ON rating
FOR EACH ROW
EXECUTE FUNCTION check_leu_livro();

-- Verifica se usuário já leu o livro para inserir um review nele
CREATE TRIGGER review_livro_lido
BEFORE INSERT ON review
FOR EACH ROW
EXECUTE FUNCTION check_leu_livro();

INSERT INTO Language (LangLabel, LangCode) VALUES
('en-US', '95313fdd-f598-4896-b7dc-5c3f11c32ba5'),
('eng', '9e3350ca-de09-41cc-a828-8226a8ad042c'),
('eng', '48fc0d28-1c5d-4a82-ad5c-cc38125fae10'),
('ger', '7c7aa4ac-8c21-4f00-a59b-f99645e48d0e'),
('eng', '0c851668-9b0b-429c-9dfd-80af046ac3ac'),
('eng', '0ae26065-910b-46bc-bd58-253ac8f4b238'),
('en-GB', '65c3b520-8095-4813-aad9-22d2b15b8f63'),
('eng', '8fea1975-58dd-4deb-b233-0b242c4cdafc'),
('eng', '6cc3ad6d-5a0c-463e-a9ae-51cc4cedb618'),
('eng', '84ec000a-ae5a-4b60-bb74-5ec9ea78283e');

INSERT INTO Publisher (PubLabel, PubCode) VALUES
('Hay House', '579ec69b-e5c6-4e73-aa49-4a05714011f0'),
('HarperOne', '8a9843a5-18ff-4d5b-ac5b-9d1e4a27c0a4'),
('Scribner', '6169f7b5-5454-4a53-b8f6-7f93964e88df'),
('List', 'ed1a5a54-b180-4a91-8c6e-ff032f242810'),
('Penguin Books', '3a5d26f0-ba33-4967-8b0e-13cee7ab26ed'),
('DC Comics', '1a8df415-2a6a-4304-80eb-83b7ec9533b9'),
('Chu Hartley Publishers LLC', '83b9bee5-5998-47e4-905d-e1b2b90578e8'),
('High Point Media', '85eadaca-9671-4b86-aab5-8d56c011cc8e'),
('Barnes  Noble Classics', '9a0fae2c-fcd7-4ea1-b3c5-0cbd9d4ad3c7'),
('Random House Audio', '79e08d30-afc5-4088-8ef8-4671ace2bf4b');

INSERT INTO Country (CtryLabel, CtryCode) VALUES
('China', '7edd1309-6a97-4e01-9b72-c6b92fe76599'),
('India', '70a3a42d-528c-4e7e-a288-50ff68ef0147'),
('United States', '2c1b8cc4-7bba-4d0d-b095-310e878636e3'),
('Indonesia', '7f4f16fa-60cb-4f8e-92b3-1bf6bd6f9493'),
('Pakistan', '7ea40b37-64ea-4c26-8199-624b0c81723d'),
('Brazil', '0b29612a-a47c-4470-b6c8-753fa36bd736'),
('Nigeria', 'd55c7830-f485-4231-9d8e-276c82d2ecf2'),
('Bangladesh', '74bb00b7-8022-476f-ba36-cc914525eb1c'),
('Russia', '5539b1aa-6b14-4074-bbc4-47436df19c5f'),
('Mexico', '5cd49db4-613b-4fdb-85d8-7acde019d763'),
('Japan', '39381037-db2b-4b59-8d0e-8d47104adcca'),
('Ethiopia', '249521b6-1e3c-44cd-8946-3aadb0a2a5a1'),
('Philippines', 'b3dc19bc-01dc-44af-946e-fdbe2d03110d'),
('Egypt', '02a25208-4a80-4b8e-8a32-896c100141b7'),
('Vietnam', 'b7551ce9-305d-4f4a-af27-4cd7782c3ac6'),
('DR Congo', '0f7dc802-867f-4c0f-af1f-55bb80bf8366'),
('Turkey', '316f058a-4afb-40b9-a2b8-6ed9bbf18031'),
('Iran', 'bb83240d-685f-4c3f-beec-2acf4a3c230f'),
('Germany', '4fc721c3-7d05-43df-9edb-2d0c3f9bf17c'),
('Thailand', '9bc12129-8012-4a2b-9086-a3ea085e2686'),
('United Kingdom', 'fe9e8ae2-58b3-4770-9834-e8f52f71116b'),
('France', 'e6a9fce1-97cf-48b0-8374-269c888b8d08'),
('Italy', '7076a17d-2d89-441c-afc2-4340fda5c353'),
('Tanzania', '5cba8812-ab28-4587-af68-36ea2fbc83bc'),
('South Africa', 'b5afe1da-d14d-41ec-8a44-b93701cc95ce'),
('Myanmar (formerly Burma)', 'c34f8b0e-7bf8-4924-bd34-4c1f094be5e5'),
('Kenya', 'f09cc9e6-4bc1-41e8-85c3-16e59cbb0755'),
('South Korea', '67481b83-e269-4757-b4af-02b7f7071eae'),
('Colombia', 'aff5e5ef-f7d8-41f9-b208-395321b1b89f'),
('Uganda', '1f96781f-64d4-46c9-8d5a-c3ef468ce754');

INSERT INTO Author (AuthorLabel, AuthorCode) VALUES
('David R. Hawkins', '7376d61d-793c-49a6-aecd-65b03f04f68b'),
('Johnny Cash/Patrick   Carr', '17b02646-d138-4ea6-9768-1f635136782d'),
('Don DeLillo', '93faa8e1-5eca-476d-860a-3a949cd9f99a'),
('Eoin Colfer/Claudia Feldmann', '0062593a-be22-4f7d-8c2b-c083d4870082'),
('Kenneth Grahame/Gillian Avery', '9859edfc-1e54-491f-a0fc-5ae2d63672c5'),
('Howard Chaykin/David Tischman/J.H. Williams III/Mick Gray/Lee Loughridge', 'f097f67e-8eaf-485a-ab0b-e87747d66439'),
('Harold Bloom', 'b273f865-78a0-45ca-bae4-4d5458a49391'),
('Bill Phillips', '2099b38c-fdfa-4116-aa12-9aeb6255f171'),
('Fyodor Dostoyevsky/Constance Garnett/Joseph Frank', '91be8d7c-45ad-4aad-8225-cc97cca4a3e4'),
('Lawrence Sanders', 'aadf3102-c909-488c-8747-d4147c6bd38a');

INSERT INTO Gender (GendLabel, GendCode) VALUES
('Mystery/Thriller', 'adce6644-b116-40bd-857d-9339b35e7bea'),
('Science Fiction', 'ebe5efda-3e7f-43fc-a4e0-70ca31511984'),
('Fantasy', 'f46ac791-2e19-4a02-a1ef-81b7953c8ff9'),
('Romance', 'e7429191-f29d-4a17-b2cf-8ba28e992253'),
('Historical Fiction', 'a1734e01-7045-4937-a3e6-f36b7aa54d5a'),
('Horror', '721a9436-6f6e-42a1-889d-ca2ea6692721'),
('Young Adult', '38a89178-a22e-49b6-b041-486dea857829'),
('Literary Fiction', 'c7ba37c2-7ec5-48ba-a38c-b88412190eb4'),
('Crime/Noir', '881ac70a-3fda-4be9-894c-f8db5c4ec3e1'),
('Adventure', '8089940c-551a-47a3-b673-2b075896d1b8'),
('Biography/Autobiography', '4fe1cd7f-6435-48c5-a0d7-589f117a9c90'),
('Non-Fiction', '9057ec1e-1857-483f-b9ab-630bb0d65abb'),
('Self-Help', 'dceb08ef-c478-4570-83ce-f06a5649cbe1'),
('Memoir', 'af129f77-bd62-430b-a7c7-1706430f6a62'),
('Poetry', 'a9c822e1-3a15-4b25-ae8b-00d0684ab5fa'),
('Drama/Play', '2c861e3e-6bd4-44a5-a64c-fd143c573ad4'),
('Comedy/Humor', '7620f0cd-08a6-4b88-9e50-ff94ab41bf66'),
('Western', '851d1cf8-0121-4064-96a7-712dd326b0dd'),
('Dystopian', '51d2c99f-d94b-41ce-aaea-5a112aa73cef'),
('Childrens/Picture Book', 'e3fd58f0-ae54-470f-b94b-e0ea51b4dbb5'),
('Paranormal/Supernatural', '1ac2883a-7159-484c-9246-755d26d69353'),
('Urban Fantasy', '2a0a644c-ccc2-4059-8a8d-78335bd51910'),
('Steampunk', 'ed155172-7c53-40c5-ba57-95525d2ff5df'),
('Contemporary Fiction', 'bb89b3a3-05fc-4af2-92d4-02e9a013bb53'),
('Magical Realism', '4ce4b462-a5d6-4acd-b3ad-d09b83a14ac3'),
('Thriller/Suspense', 'db72a861-1c7d-45f3-bcc0-57d4988fdc75'),
('Espionage', '6e467296-9a36-4774-8474-3602eb204b8c'),
('War/Military Fiction', 'd6239c4f-9d9d-4d82-9274-65323ad379b7'),
('Womens Fiction', '880ae431-db87-4ee5-a14e-7f5046d44020'),
('Sports Fiction', '12bb1427-765f-4305-869b-54fd61c685b6'),
('Science/Popular Science', '79bbab4c-3ef7-45ee-adb4-c53295280382'),
('True Crime', '8bf9282b-e8a2-4dd0-b552-14895eb92bd8'),
('Cookbook/Culinary', '741dac87-4798-4392-ac25-79a2de8b62fe'),
('Travel/Adventure', '51be5a0c-c28f-41bb-964d-df0ed1dc7b68'),
('Art/Photography', '0a037015-ac29-4cd0-91e3-8398014311e9'),
('Religion/Spirituality', '90b18af2-dfbd-4651-a4a9-dd5c91ece877'),
('Philosophy', '48650757-3b30-4727-950f-2c701e57ccb3'),
('Psychology/Psychological Thriller', 'a247ac47-865e-49aa-82a4-c659324a9038'),
('LGBTQ+ Fiction', 'be211ced-7476-422f-92f6-78a3f428a0f7'),
('Post-Apocalyptic', '41bc325d-86d6-42ef-a61f-d135f0e22446'),
('Alternate History', 'b977b428-3316-457e-bed6-5e0ba7dbe34b'),
('Cyberpunk', 'e7e12c65-579e-4c90-8f8b-e455b141fe39'),
('Supernatural Romance', '53f02943-aeca-4d25-80f0-03e76d9957b7'),
('Time Travel', 'd2c67edd-aedc-4e2b-ba1c-ca23c0682a44'),
('Cozy Mystery', 'df0d539f-f59a-4650-92bc-6ee5296f1ad6'),
('Folklore/Fairy Tales', 'eadb163b-ad27-4776-98ad-8df035e653c1'),
('Graphic Novel/Comic', 'b2433578-7013-4933-b6f2-abe9c8afd931'),
('Western Romance', 'd6c586f8-e0ab-4701-9edc-d3ae69922932'),
('Short Stories/Anthology', 'ab094d0e-1147-457f-9968-53df2956c408'),
('Classic Literature', '3f1dee55-a51d-4d25-a10e-6b46f80c8e85');

INSERT INTO Book (ISBN13, Title, PageCount, RatingCount, ReviewCount, PublishingDate, CtryCode, PubCode, LangCode) VALUES
(9781561709335, 'Power vs. Force', 341, 0, 0, '5/3/2002', '7edd1309-6a97-4e01-9b72-c6b92fe76599', '579ec69b-e5c6-4e73-aa49-4a05714011f0', '95313fdd-f598-4896-b7dc-5c3f11c32ba5'),
(9780060727536, 'Cash', 310, 0, 0, '7/10/2003', '1f96781f-64d4-46c9-8d5a-c3ef468ce754', '8a9843a5-18ff-4d5b-ac5b-9d1e4a27c0a4', '9e3350ca-de09-41cc-a828-8226a8ad042c'),
(9780743273060, 'Love-Lies-Bleeding', 112, 0, 0, '10/1/2006', 'f09cc9e6-4bc1-41e8-85c3-16e59cbb0755', '6169f7b5-5454-4a53-b8f6-7f93964e88df', '48fc0d28-1c5d-4a82-ad5c-cc38125fae10'),
(9783548603209, 'Artemis Fowl (Artemis Fowl  #1)', 240, 0, 0, '1/5/2003', 'b3dc19bc-01dc-44af-946e-fdbe2d03110d', 'ed1a5a54-b180-4a91-8c6e-ff032f242810', '7c7aa4ac-8c21-4f00-a59b-f99645e48d0e'),
(9780143039099, 'The Wind in the Willows', 197, 0, 0, '27/10/2005', 'd55c7830-f485-4231-9d8e-276c82d2ecf2', '3a5d26f0-ba33-4967-8b0e-13cee7ab26ed', '0c851668-9b0b-429c-9dfd-80af046ac3ac'),
(9781563895951, 'Son of Superman', 95, 0, 0, '1/1/2000', '249521b6-1e3c-44cd-8946-3aadb0a2a5a1', '1a8df415-2a6a-4304-80eb-83b7ec9533b9', '0ae26065-910b-46bc-bd58-253ac8f4b238'),
(9780978721008, 'The American Religion', 305, 0, 0, '1/10/2006', '7edd1309-6a97-4e01-9b72-c6b92fe76599', '83b9bee5-5998-47e4-905d-e1b2b90578e8', '65c3b520-8095-4813-aad9-22d2b15b8f63'),
(9780972018418, 'Eating for Life: Your Guide to Great Health  Fat Loss and Increased Energy!', 405, 0, 0, '26/11/2003', 'aff5e5ef-f7d8-41f9-b208-395321b1b89f', '85eadaca-9671-4b86-aab5-8d56c011cc8e', '8fea1975-58dd-4deb-b233-0b242c4cdafc'),
(9785170211579, 'The Idiot', 559, 0, 0, '6/1/2005', 'aff5e5ef-f7d8-41f9-b208-395321b1b89f', '9a0fae2c-fcd7-4ea1-b3c5-0cbd9d4ad3c7', '6cc3ad6d-5a0c-463e-a9ae-51cc4cedb618'),
(9780871881786, 'First Deadly Sin', 17, 0, 0, '1/7/1989', '5cba8812-ab28-4587-af68-36ea2fbc83bc', '79e08d30-afc5-4088-8ef8-4671ace2bf4b', '84ec000a-ae5a-4b60-bb74-5ec9ea78283e');

INSERT INTO HasGender (HasGendCode, ISBN13, GendCode) VALUES
('0f4ec74a-26bd-4c4b-8d2c-2e020b565731', 9781561709335, 'f46ac791-2e19-4a02-a1ef-81b7953c8ff9'),
('caaff0a9-f0ce-42d3-b14b-3d27641792cc', 9780060727536, '8089940c-551a-47a3-b673-2b075896d1b8'),
('06c14318-546f-46b9-a68b-de7e495b8100', 9780743273060, '6e467296-9a36-4774-8474-3602eb204b8c'),
('09a441c8-5ee9-4792-86c2-1f86108da424', 9783548603209, 'a9c822e1-3a15-4b25-ae8b-00d0684ab5fa'),
('228aad2c-96f2-4338-bb07-8d974ec8fb64', 9780143039099, '9057ec1e-1857-483f-b9ab-630bb0d65abb'),
('f3ae4730-2870-4551-bb46-aac8e26a25d9', 9781563895951, 'b977b428-3316-457e-bed6-5e0ba7dbe34b'),
('1494fa6e-6cb9-46ba-8c8f-23eaba5c479a', 9780978721008, 'd6239c4f-9d9d-4d82-9274-65323ad379b7'),
('4054e9fe-cdaf-45af-9e6e-f94270527ad8', 9780972018418, 'ed155172-7c53-40c5-ba57-95525d2ff5df'),
('7993fce8-f768-407c-ac87-3a8b6c439276', 9785170211579, '721a9436-6f6e-42a1-889d-ca2ea6692721'),
('93446723-2f72-40ee-9372-f6e36dcd5bba', 9780871881786, 'd6c586f8-e0ab-4701-9edc-d3ae69922932');

INSERT INTO WrittenBy (WrittenByCode, ISBN13, AuthorCode) VALUES
('7f3d5097-5d5e-4cbb-adee-fba373513039', 9781561709335, '7376d61d-793c-49a6-aecd-65b03f04f68b'),
('608b0987-cb1b-416b-98c9-0c1944199680', 9780060727536, '17b02646-d138-4ea6-9768-1f635136782d'),
('9369842e-27b7-4f87-8557-9d14c6ac16cf', 9780743273060, '93faa8e1-5eca-476d-860a-3a949cd9f99a'),
('8adbd8fe-c6b9-4b80-b431-ce909bbc4c18', 9783548603209, '0062593a-be22-4f7d-8c2b-c083d4870082'),
('e2551755-8bee-46e4-9c74-1800515741cf', 9780143039099, '9859edfc-1e54-491f-a0fc-5ae2d63672c5'),
('13c1cdee-1c83-4188-b0ce-e0c6e4033882', 9781563895951, 'f097f67e-8eaf-485a-ab0b-e87747d66439'),
('d017ec44-0078-4fb4-ae47-52ced782516c', 9780978721008, 'b273f865-78a0-45ca-bae4-4d5458a49391'),
('09f9ceea-3429-4a06-9a78-e4073592b0d0', 9780972018418, '2099b38c-fdfa-4116-aa12-9aeb6255f171'),
('aa1c7849-1a56-4833-b213-4a6b88314e03', 9785170211579, '91be8d7c-45ad-4aad-8225-cc97cca4a3e4'),
('10dc2a3d-1d9c-4894-a4a8-3748bbf4ee24', 9780871881786, 'aadf3102-c909-488c-8747-d4147c6bd38a');

INSERT INTO GoodreadsUser (UserCode, Age, UserName, Sex, Email) VALUES
('2f8b14eb-3604-46c1-963a-c59096d7f221', 82, 'bobbrown9', 'F', 'bobbrown18@gmail.com'),
('79042567-0542-4e76-ba69-0ce30dc28492', 88, 'frankfranklin33', 'F', 'frankfranklin59@gmail.com'),
('52f873a3-8341-4495-b8d3-4049853a894c', 44, 'charliechen28', 'M', 'charliechen28@gmail.com'),
('67ff71fa-ba13-4119-a587-2aaf5d10a1e9', 88, 'yarayoung47', 'M', 'yarayoung91@gmail.com'),
('734a58ba-d390-4cc8-b59b-ea53a7e505e2', 69, 'zanezimmerman94', 'M', 'zanezimmerman46@gmail.com'),
('0f940f01-0727-4244-8667-6ce3f8272ee1', 63, 'frankfranklin97', 'M', 'frankfranklin92@gmail.com'),
('fffbfe8f-b931-47c0-b37a-8d3365dd23c2', 53, 'oliviaortiz14', 'M', 'oliviaortiz10@gmail.com'),
('b762413a-393d-4caf-b184-549a3615d1e8', 31, 'bobbrown94', 'M', 'bobbrown36@gmail.com'),
('3d62eb40-b618-43f0-89d5-08a4408d2ab6', 65, 'umaupton9', 'M', 'umaupton28@gmail.com'),
('d310a5ac-ae6c-4e37-b10a-4521f6e79113', 80, 'paulphillips34', 'M', 'paulphillips35@gmail.com');

INSERT INTO Rating (RtgCode, NumberOfStars, UserCode, ISBN13) VALUES
('b60c3480-675a-44a4-9392-b425a6b8f66b', 0, '2f8b14eb-3604-46c1-963a-c59096d7f221', '9780978721008'),
('5766c159-4279-4997-af15-a91e9cfdfb25', 1, '2f8b14eb-3604-46c1-963a-c59096d7f221', '9783548603209'),
('4c851c0c-c78b-4d3c-9a27-92818285e866', 5, '2f8b14eb-3604-46c1-963a-c59096d7f221', '9783548603209'),
('061ecf3c-54ec-49ed-a523-2007b1883fdf', 2, '2f8b14eb-3604-46c1-963a-c59096d7f221', '9780978721008'),
('f47fb8ac-595b-40c9-a2b6-a2c18fce3e43', 0, '2f8b14eb-3604-46c1-963a-c59096d7f221', '9780143039099'),
('43688b37-3884-4282-8169-f17de4344036', 4, '2f8b14eb-3604-46c1-963a-c59096d7f221', '9781561709335'),
('b8f5a24a-3cd5-44a0-9df6-995f51451cbf', 2, '2f8b14eb-3604-46c1-963a-c59096d7f221', '9780871881786'),
('25079295-1943-4d3d-be40-6d73a3dcf11d', 1, '2f8b14eb-3604-46c1-963a-c59096d7f221', '9785170211579'),
('49c7891a-950f-4f77-ab9f-5212289b46bf', 0, '2f8b14eb-3604-46c1-963a-c59096d7f221', '9781561709335'),
('7c6c22a1-fd48-4cfb-bf7a-83a5dd3147f6', 5, '2f8b14eb-3604-46c1-963a-c59096d7f221', '9780143039099'),
('b3cc606f-2525-4d90-85fb-cebf69d722f8', 5, '2f8b14eb-3604-46c1-963a-c59096d7f221', '9783548603209'),
('54d1e577-b57c-4681-b3c6-d689cb99b784', 1, '2f8b14eb-3604-46c1-963a-c59096d7f221', '9781561709335'),
('e26dfb7f-4c65-41e2-b23a-a22c4884d724', 1, '2f8b14eb-3604-46c1-963a-c59096d7f221', '9780972018418'),
('4fc3533e-4739-40ea-a923-7068a19dafd8', 0, '2f8b14eb-3604-46c1-963a-c59096d7f221', '9780871881786'),
('56140ff8-016a-4540-8ff1-d6ed159ae8d8', 2, '79042567-0542-4e76-ba69-0ce30dc28492', '9781563895951'),
('5b8f90bd-154a-4f54-8897-94cce8ac3e03', 3, '79042567-0542-4e76-ba69-0ce30dc28492', '9783548603209'),
('8aeef209-614e-4044-a72d-8af2756d45f4', 4, '79042567-0542-4e76-ba69-0ce30dc28492', '9780743273060'),
('72a13723-26ff-4044-990d-82a59b98addf', 3, '79042567-0542-4e76-ba69-0ce30dc28492', '9781563895951'),
('24955400-de2f-410a-9bb7-4d6de14fa59f', 3, '79042567-0542-4e76-ba69-0ce30dc28492', '9780972018418'),
('38e4d472-11ab-45ca-8ca1-e442fd94cf03', 5, '79042567-0542-4e76-ba69-0ce30dc28492', '9785170211579'),
('64d72b48-11c8-4395-a7bd-41fc6d2a3e9e', 1, '79042567-0542-4e76-ba69-0ce30dc28492', '9785170211579'),
('4186c914-851f-494d-9ca3-b2183438b1d7', 2, '79042567-0542-4e76-ba69-0ce30dc28492', '9780743273060'),
('d2e3b7e8-250e-4760-b77f-cf8d5f5b12b4', 0, '79042567-0542-4e76-ba69-0ce30dc28492', '9780871881786'),
('c576c270-bd17-4dde-bcb2-a89028ec104a', 1, '79042567-0542-4e76-ba69-0ce30dc28492', '9783548603209'),
('b0e87d01-f744-4df9-880d-71f16dbf6b1f', 0, '79042567-0542-4e76-ba69-0ce30dc28492', '9780978721008'),
('d231200f-83d7-4e44-8226-8b1c60e6c64f', 0, '79042567-0542-4e76-ba69-0ce30dc28492', '9783548603209'),
('896d565d-be2f-456b-b559-2198b07726b9', 4, '79042567-0542-4e76-ba69-0ce30dc28492', '9781561709335'),
('037a6d14-37e2-462e-a476-ea67ce29874e', 0, '79042567-0542-4e76-ba69-0ce30dc28492', '9781561709335'),
('15206a38-90a4-4fb0-9780-8e1dc02451e8', 0, '79042567-0542-4e76-ba69-0ce30dc28492', '9781563895951'),
('19fefef9-a32f-4577-ae91-fa9662d052dd', 1, '79042567-0542-4e76-ba69-0ce30dc28492', '9780972018418'),
('3406bb3f-696e-43fa-a04b-8fdd597070ec', 4, '79042567-0542-4e76-ba69-0ce30dc28492', '9780060727536'),
('f34f634d-fbad-4523-9811-059d6c766dc2', 2, '79042567-0542-4e76-ba69-0ce30dc28492', '9780743273060'),
('bf24a58f-32fd-4b78-abd7-860c2db19608', 0, '79042567-0542-4e76-ba69-0ce30dc28492', '9780143039099'),
('41615c22-29d8-4092-834b-40dd66587ea9', 3, '79042567-0542-4e76-ba69-0ce30dc28492', '9781563895951'),
('68edf263-3fda-4c71-8188-8216daecae4e', 5, '52f873a3-8341-4495-b8d3-4049853a894c', '9780871881786'),
('9ba7f22e-6bbd-4e4c-a4c7-5b97a80bb988', 4, '52f873a3-8341-4495-b8d3-4049853a894c', '9780972018418'),
('047295e9-7dca-48ba-a163-1ae4ca5f972b', 3, '52f873a3-8341-4495-b8d3-4049853a894c', '9780143039099'),
('48cab31b-7458-4538-bfed-1f7b7085d2cd', 3, '52f873a3-8341-4495-b8d3-4049853a894c', '9780060727536'),
('dac0bd15-7eff-4125-9041-34b353c19711', 5, '52f873a3-8341-4495-b8d3-4049853a894c', '9781563895951'),
('096f7d70-ad94-41f1-9b3f-827ebd64af05', 1, '52f873a3-8341-4495-b8d3-4049853a894c', '9780060727536'),
('8841f118-bad1-4cd3-b2fc-3167d486e03a', 1, '52f873a3-8341-4495-b8d3-4049853a894c', '9780871881786'),
('36550687-a9c5-4fa1-85f9-478e15c6b289', 4, '52f873a3-8341-4495-b8d3-4049853a894c', '9781563895951'),
('18f7d8ba-efc1-497e-959a-0836380547c6', 0, '52f873a3-8341-4495-b8d3-4049853a894c', '9780871881786'),
('05937384-bb29-4479-89f5-d0efa007995d', 2, '52f873a3-8341-4495-b8d3-4049853a894c', '9780743273060'),
('c1049ee9-b75d-4e78-bc22-7f8ce1921a96', 0, '52f873a3-8341-4495-b8d3-4049853a894c', '9780143039099'),
('d49d27af-188c-446e-8100-523fb1ed1ced', 1, '52f873a3-8341-4495-b8d3-4049853a894c', '9780978721008'),
('efa0c582-a0f7-443c-aeb3-c231f70e2a79', 5, '52f873a3-8341-4495-b8d3-4049853a894c', '9780060727536'),
('c3327d08-c511-4c7f-8288-317a94d7dd57', 4, '52f873a3-8341-4495-b8d3-4049853a894c', '9780871881786'),
('d3fbb7cd-e38f-4405-afe5-3105eac4b02a', 3, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780743273060'),
('ddae8f5f-4ac4-46e6-bcfa-8580b485743e', 4, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780743273060'),
('6bcdf7cf-6fe7-437e-986e-ec3a33c44b79', 0, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9785170211579'),
('b3b614a4-7c15-4d83-bd44-3244d94ec438', 0, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780972018418'),
('02cb9669-0e3e-49b7-8c28-0f3a20354016', 3, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780978721008'),
('f6f8139f-66b2-409a-921f-feb09bc4afc9', 4, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780060727536'),
('53cd7637-21d2-4e95-a351-a5134caa1618', 5, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780978721008'),
('12ffc2c1-7528-4a8f-9b01-48abebd3b25c', 2, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780743273060'),
('cb3c1060-8bba-4340-a7c1-639d8ce538d7', 1, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9785170211579'),
('67e66f09-c25d-4f71-bf8d-f67f8d72ecf4', 2, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780871881786'),
('fc98c754-dc93-43aa-96c0-dbedd3adf9f8', 4, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780978721008'),
('714d4996-4c4b-4a8c-b5d1-abd63ceadd99', 1, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780978721008'),
('8ad69496-c06d-4015-a6b6-754215fcac49', 5, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9781561709335'),
('899deb98-16fe-40db-b4f3-680d808efe99', 0, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780743273060'),
('8a342171-e947-4c7e-bc67-8a58a76222ba', 1, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780978721008'),
('77cdd7b2-1270-4f78-be09-0817278d2604', 1, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780972018418'),
('5e80b82d-d41d-4e55-8acd-5114f46fdc4e', 4, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780871881786'),
('06a5f476-3b8a-412d-a714-a5f6ce18003a', 4, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780972018418'),
('8d5b6d46-9328-4ba3-a2cb-bb6e558457d1', 3, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780060727536'),
('abb79bf2-c5ed-4680-9dfe-136ffbe3d611', 0, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9785170211579'),
('5c7d515f-997b-4d5f-b793-9159958fb67a', 2, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780143039099'),
('8f0325ce-4fdb-468c-8a2b-1e8b75241076', 4, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780743273060'),
('606d59d4-92a1-4bf7-9429-36e81612159b', 4, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780743273060'),
('8bfddcb7-3e49-46f1-9c77-031c16766035', 0, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9781561709335'),
('666182d6-afb7-4427-8d8d-1da835ee94ad', 3, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9781563895951'),
('e77edf5b-5d29-489a-8157-f05d5b4eb5bc', 1, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780143039099'),
('fae87fee-4ced-48e2-8842-b6fcaf22335d', 4, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780972018418'),
('c9f7aae2-384c-44e4-a758-170644601058', 2, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780978721008'),
('dfbd19a0-ce14-4b17-9fe5-b36eb7b5fc88', 2, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9783548603209'),
('2ae1d9eb-089e-4056-850f-45c3adabc6bb', 3, '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780871881786'),
('a5fd2b78-0de5-407f-ba4a-51f10812d26f', 3, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9783548603209'),
('fb96a416-5c06-4ecf-8d78-103abbcd9645', 3, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9780060727536'),
('328040f3-87de-42de-9588-dcca2874cec5', 3, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9780978721008'),
('8d0eb60c-f543-4169-8737-59f669cd4856', 0, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9785170211579'),
('58a89313-b85b-479d-abcd-081597f82b01', 1, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9780060727536'),
('68c4bec2-2fb5-4505-98ce-29ab73e859b9', 4, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9781561709335'),
('3a648bdd-b04b-4656-91c1-945e3d86096b', 1, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9780060727536'),
('5f2d253c-0583-4b20-b4b1-fb94589d2b73', 5, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9783548603209'),
('985297d3-c575-48cb-ba8a-d4671a47e09c', 5, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9781561709335'),
('5ba03312-5d44-4204-9cce-c2d69e112bc7', 1, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9781563895951'),
('aede925e-ebcd-4dcd-b56e-a070595c1aa6', 3, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9783548603209'),
('e6d48419-4886-44d6-a30d-dd769f91051b', 0, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9780871881786'),
('d8e0721a-65f1-43b4-86f8-4dedbd8fd665', 2, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9781561709335'),
('2a1190fb-10c5-4ec9-9e60-38d90a7dee69', 1, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9780060727536'),
('d686d883-280b-4404-8b6a-0c4bd730453d', 4, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9780972018418'),
('68821a96-41b8-4602-8b86-81c8ac519bd1', 5, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9783548603209'),
('266bbfb7-0ede-425d-87cb-5a7ec6960b46', 4, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9780978721008'),
('805e0a25-3091-453f-be21-de3ff78eab52', 0, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9780060727536'),
('0c5c2297-af8a-4d93-9043-facd14ad702b', 0, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9780871881786'),
('d9851dcd-fd35-4c51-9c00-349d00ed04e4', 1, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9780143039099'),
('bd84a694-9347-48e4-b237-c0fd17a5107d', 0, '0f940f01-0727-4244-8667-6ce3f8272ee1', '9781563895951'),
('db9d523b-ba1a-4c54-8a0a-3436af2fd6c4', 1, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9780060727536'),
('0bc84805-f980-4a80-91ee-9e848fd73cfc', 0, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9783548603209'),
('46e10281-877f-4555-922f-33d948f3cd7e', 2, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9781563895951'),
('a764ef88-a688-42ce-ad86-cc79c76461b9', 5, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9780060727536'),
('97fea48b-e170-4906-b7f9-9d51cc2bff32', 1, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9780060727536'),
('5096b6a2-0b33-4f54-bdc4-8a67d2bbed44', 4, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9781561709335'),
('0803098c-32cc-445c-9a48-0f1ff7d54665', 4, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9780871881786'),
('c7804f56-ebef-4b55-b557-608160073d77', 4, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9780743273060'),
('2477e4ba-f028-4179-ada1-eebcaad2cf3b', 1, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9783548603209'),
('c91afdc8-4fcf-44fb-ae81-ba24b30a5e83', 0, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9785170211579'),
('9cd46b18-70fe-4d9c-a9af-e89b50740691', 1, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9785170211579'),
('26333c08-8edd-48aa-8ae1-44a115b979ab', 3, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9780871881786'),
('5ca501ab-cb5c-4aef-a127-53d70d931f01', 3, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9785170211579'),
('cf768773-1e33-47a7-8533-e90e7c25d0d0', 5, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9780143039099'),
('19b1035b-b068-404d-8d43-c1693310da0a', 4, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9780143039099'),
('86a00343-c1d1-4730-b4d1-561bd4314adf', 4, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9780972018418'),
('ad245c40-504c-4c4b-a0dc-b6919c73112b', 1, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9780743273060'),
('7df1bdf9-5770-4d71-bf46-883b106353d4', 0, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9783548603209'),
('1830e270-62a1-40fb-8f2b-67289b4ddcd7', 3, 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9780743273060'),
('ae7e1da3-69e2-4cda-a743-fa4dbb9930dc', 4, 'b762413a-393d-4caf-b184-549a3615d1e8', '9785170211579'),
('19168629-df16-4725-833c-32394cde2d16', 4, 'b762413a-393d-4caf-b184-549a3615d1e8', '9780143039099'),
('8a050570-ce70-46e6-9c74-6333ddc3f948', 4, 'b762413a-393d-4caf-b184-549a3615d1e8', '9783548603209'),
('36108089-9d47-4bea-9f16-8e94b879ec73', 3, 'b762413a-393d-4caf-b184-549a3615d1e8', '9781561709335'),
('4f9095d6-ebef-4291-9f7b-38d5134ee735', 0, 'b762413a-393d-4caf-b184-549a3615d1e8', '9781563895951'),
('1fad8d12-012d-444a-ad7a-cca7fa8e9329', 2, 'b762413a-393d-4caf-b184-549a3615d1e8', '9780871881786'),
('d8db6093-fb3a-4e6b-a57c-091509a3d2b4', 4, 'b762413a-393d-4caf-b184-549a3615d1e8', '9781563895951'),
('6f41af8f-ce06-4b14-8d51-26a20078ba60', 1, 'b762413a-393d-4caf-b184-549a3615d1e8', '9783548603209'),
('0b9352f1-356c-4662-9ae8-c66197a2be15', 4, 'b762413a-393d-4caf-b184-549a3615d1e8', '9780743273060'),
('46f1e6bc-a305-4e94-895d-c8674547567f', 1, 'b762413a-393d-4caf-b184-549a3615d1e8', '9780743273060'),
('3799ab1e-b10f-422c-82e0-c96734975694', 1, 'b762413a-393d-4caf-b184-549a3615d1e8', '9780060727536'),
('c7f1cf1e-43c6-4413-9c9f-344a0bd2b4c3', 4, 'b762413a-393d-4caf-b184-549a3615d1e8', '9780871881786'),
('85d3715c-fa5f-4f62-be3b-dd342ce51978', 1, 'b762413a-393d-4caf-b184-549a3615d1e8', '9780060727536'),
('aea0130d-a636-4e5e-b499-d05f38acc70e', 1, 'b762413a-393d-4caf-b184-549a3615d1e8', '9780871881786'),
('9a6af53c-9fe8-4f11-b8cd-8babb73b4548', 4, 'b762413a-393d-4caf-b184-549a3615d1e8', '9781563895951'),
('49627dc4-4f1b-4eb9-8394-583b11aa9798', 2, 'b762413a-393d-4caf-b184-549a3615d1e8', '9780972018418'),
('16af7f20-03cb-4f40-b9bd-4c98ead49e6f', 4, 'b762413a-393d-4caf-b184-549a3615d1e8', '9785170211579'),
('9c32c046-9e7e-4fa2-8d05-8d58370cf5f5', 3, 'b762413a-393d-4caf-b184-549a3615d1e8', '9781561709335'),
('6f017019-d3e9-4931-902e-0d800b3ad277', 4, 'b762413a-393d-4caf-b184-549a3615d1e8', '9780060727536'),
('feb16e47-ae14-4998-ba58-37a89a7566a2', 4, 'b762413a-393d-4caf-b184-549a3615d1e8', '9781561709335'),
('8c8e052f-6239-460c-9a89-86c4a14d4f99', 4, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780060727536'),
('9ba0a545-9b0d-49ff-9319-75f85b993f3d', 0, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780743273060'),
('baae0afc-6195-4486-b6a1-aa40f011b9ab', 1, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9781563895951'),
('b663c472-163c-4f45-a28a-310737f3f5f0', 0, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9781563895951'),
('aa81fab8-c551-40e9-af34-aadbf90cbea9', 0, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780143039099'),
('d0925706-b5c2-411f-b60b-085f11f5dd93', 4, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780871881786'),
('1a88ad71-ce12-4c81-aba7-9c5071a2a57a', 4, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780060727536'),
('9ffc01f9-91d1-464d-907f-3296c53cde98', 2, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780743273060'),
('d25645ab-6b2e-4676-aeda-682f75abd43b', 1, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780871881786'),
('a905461e-0a54-439b-bfc2-85c4e936b37d', 5, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780978721008'),
('919038a0-c207-417b-968d-2cec4c3df84c', 3, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9781561709335'),
('8f170cb7-c989-4af3-a40a-4696f3829734', 3, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780143039099'),
('887e7223-3434-4848-bcc7-2211eaa6b88b', 2, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9781561709335'),
('9cc7d005-b2aa-435b-88b1-9db82e288d1c', 3, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780143039099'),
('ebd5153d-a142-4ff6-9e69-06729a653142', 4, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780871881786'),
('b43c401e-1ae1-432c-a23f-2d7fef96a0e5', 0, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780143039099'),
('51d42baa-a813-4f69-8796-a8cf1c13460d', 3, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780743273060'),
('961d135e-2b48-4ec3-bd97-2c4091c59474', 5, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9783548603209'),
('07baac71-1755-455e-b3ec-11000f307371', 5, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9785170211579'),
('519771d9-0bd4-47a4-8e1d-6d17efeb9ffb', 2, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780060727536'),
('c70a3e13-530f-47c2-a1af-08a8e6e0189a', 4, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9781563895951'),
('6d2f1192-faf5-4a41-b295-fac59f4c2c3f', 5, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9781561709335'),
('23183686-f988-4fb1-b0dc-720b6dfd0c98', 4, '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780871881786'),
('40023ead-e242-4b73-82a6-2614b73737f8', 3, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9780060727536'),
('140d493b-6500-4a58-8c33-dad585053334', 5, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9781561709335'),
('fca3cd92-800b-4341-a83d-5781f7468852', 2, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9783548603209'),
('c9bd210e-2deb-4872-bb61-77371668c19e', 1, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9780143039099'),
('ce9fb8e5-a13f-4729-9c9b-446254cf1dce', 3, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9785170211579'),
('9b0e2a76-c7cf-46f6-b616-110b7c44de40', 0, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9780972018418'),
('4c9ac35a-0965-4040-a3be-bc9509a38ca1', 0, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9780060727536'),
('aba5e348-f1a6-4db9-a131-24e0841bd91d', 4, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9781561709335'),
('f9807069-cb8d-4694-bfb9-9a5f97374143', 3, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9781561709335'),
('509fe8be-fee2-4c83-80c2-b38504e06356', 3, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9780143039099'),
('edc9daca-dd23-4be9-8b9f-c6b9f7ff45f4', 1, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9780143039099'),
('5deb9682-f0a1-4af8-8049-519e564eeef9', 0, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9780743273060'),
('204b9475-5b46-4ca9-a5e4-d091a4313a93', 5, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9780972018418'),
('944990e5-8c14-4812-9aef-786cf1356d4b', 0, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9780972018418'),
('546a6b2e-d07a-46d8-ad1c-44d3a468b0b9', 0, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9780743273060'),
('c434f049-800e-4b67-8734-c0fa9d2a315b', 3, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9785170211579'),
('fa25e84e-0912-42be-80ae-7fd9cffc41bd', 0, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9783548603209'),
('ffda9403-68bc-407c-8665-c33285460f5a', 5, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9781561709335'),
('99604672-c14d-41fb-9a1b-106ecced0fe1', 5, 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9780972018418');

INSERT INTO Review (RvwCode, Text, UserCode, ISBN13) VALUES
('a5456645-cda3-476f-adfb-896ab06a1068', 'A thrilling page-turner with unexpected twists and turns. Couldnt put it down!', '67ff71fa-ba13-4119-a587-2aaf5d10a1e9', '9781561709335'),
('5962953f-4a16-4928-84a6-1801a732d5db', 'A beautifully written and evocative book that transports readers to a different era. A must-read for historical fiction enthusiasts.', '67ff71fa-ba13-4119-a587-2aaf5d10a1e9', '9780972018418'),
('c8981502-65ea-4675-8e57-d5f9d2c37481', 'An epic and sweeping saga that spans generations. A masterful work of historical fiction.', '0f940f01-0727-4244-8667-6ce3f8272ee1', '9780060727536'),
('7582cf4c-30f6-4ea0-bc73-35fefc1582ad', 'An epic and sweeping saga that spans generations. A masterful work of historical fiction.', 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9780743273060'),
('b739a455-91a4-4601-ae55-1eb1f21b681f', 'A witty and humorous novel that had me laughing out loud. A delightful and entertaining read.', 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9781561709335');

INSERT INTO BookshelfBook (BookshelfBookCode, BookStatus, UserCode, ISBN13) VALUES
('a07d7d64-cb35-4313-9dad-4ccf273d708c', 'Read', '52f873a3-8341-4495-b8d3-4049853a894c', '9780871881786'),
('e9b80197-cd17-4e52-9ad0-edbc81dcad9d', 'Read', '52f873a3-8341-4495-b8d3-4049853a894c', '9781561709335'),
('6ada7180-e30d-4161-8cc2-4305408bde66', 'Reading', '67ff71fa-ba13-4119-a587-2aaf5d10a1e9', '9780871881786'),
('fc6500cf-5df4-4122-8370-7b6cee7aac3b', 'Reading', '67ff71fa-ba13-4119-a587-2aaf5d10a1e9', '9780972018418'),
('97a24882-1af4-4fa7-b5e5-cb688002821c', 'Reading', '67ff71fa-ba13-4119-a587-2aaf5d10a1e9', '9780060727536'),
('e0d03c37-6c5b-4b07-a160-f171e2c3bd2b', 'Want To Read', '67ff71fa-ba13-4119-a587-2aaf5d10a1e9', '9781563895951'),
('e035d640-2d36-4bc8-a371-574407379c93', 'Want To Read', '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9785170211579'),
('3f748238-d33b-4d13-ade4-679ba156cb61', 'Read', '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9781561709335'),
('51748ef6-8fc9-4622-958f-7947c5d56229', 'Reading', '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9781563895951'),
('8d9d606b-1bde-45ca-a95e-880bceca5454', 'Reading', '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '9780972018418'),
('33e80cd3-34ab-4a23-b0ff-d47542f601fb', 'Read', '0f940f01-0727-4244-8667-6ce3f8272ee1', '9780978721008'),
('bb58eda7-1766-4767-92b4-957b166751ee', 'Reading', '0f940f01-0727-4244-8667-6ce3f8272ee1', '9785170211579'),
('bcddd072-c41f-4a70-8390-8418ce06935f', 'Read', '0f940f01-0727-4244-8667-6ce3f8272ee1', '9781561709335'),
('fb80d10e-29e8-43a2-91d5-4834ef9be105', 'Want To Read', '0f940f01-0727-4244-8667-6ce3f8272ee1', '9780978721008'),
('282cb8ea-fae4-4db2-8540-a85e9caff9ce', 'Want To Read', '0f940f01-0727-4244-8667-6ce3f8272ee1', '9780972018418'),
('dcfde203-1e3f-42e3-848c-b6b0028786fb', 'Reading', 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9780743273060'),
('0c28e65f-bb9b-4e10-a3cc-3c2a4143c37c', 'Reading', 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9783548603209'),
('43a569a5-98f4-4e74-bee8-24ae9311d1ee', 'Want To Read', 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9780060727536'),
('22e574fc-94b8-4d28-b457-34d454b45a5d', 'Want To Read', 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '9783548603209'),
('9c034b4b-47e9-4191-811b-9c4d3815915c', 'Read', '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780972018418'),
('ad41d6eb-8604-4db2-afc0-0119823b099a', 'Reading', '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9785170211579'),
('2f17bc5a-fd8a-411b-a0b2-2df7ac298376', 'Want To Read', '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '9780060727536'),
('c8ab591b-9bc4-4eb1-b5bc-0e371ac709db', 'Reading', 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9781563895951'),
('c19ebde3-993c-4972-ae0d-d2ae96a4b258', 'Reading', 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9781563895951'),
('0fa9f6aa-406b-43c7-a9be-455702a34eb3', 'Reading', 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '9780972018418');

INSERT INTO Follows (FlwCode, UserACode, UserBCode) VALUES
('a5e8f1c5-3301-414f-9e07-b89be63530d7', '2f8b14eb-3604-46c1-963a-c59096d7f221', '79042567-0542-4e76-ba69-0ce30dc28492'),
('f216aabe-84d4-4224-a55d-2ad3d2b31fec', '2f8b14eb-3604-46c1-963a-c59096d7f221', '52f873a3-8341-4495-b8d3-4049853a894c'),
('43e97692-c3a4-446c-8073-c23a225a6fad', '2f8b14eb-3604-46c1-963a-c59096d7f221', '0f940f01-0727-4244-8667-6ce3f8272ee1'),
('5da2d178-1c27-4904-8a5e-dedb4d7c6f19', '2f8b14eb-3604-46c1-963a-c59096d7f221', 'b762413a-393d-4caf-b184-549a3615d1e8'),
('5c54dccd-5813-44c4-a8a8-221c9b3e40b5', '2f8b14eb-3604-46c1-963a-c59096d7f221', '3d62eb40-b618-43f0-89d5-08a4408d2ab6'),
('ca7d5e92-d321-4f61-8518-8b1763a5a022', '79042567-0542-4e76-ba69-0ce30dc28492', '67ff71fa-ba13-4119-a587-2aaf5d10a1e9'),
('ad820ed7-60f4-42ce-8c3b-36ddc518ce3f', '79042567-0542-4e76-ba69-0ce30dc28492', '734a58ba-d390-4cc8-b59b-ea53a7e505e2'),
('b5402077-db3f-4aa2-a509-43670e636b46', '79042567-0542-4e76-ba69-0ce30dc28492', 'd310a5ac-ae6c-4e37-b10a-4521f6e79113'),
('17fb4cad-4920-4a49-947d-38c99655c5af', '52f873a3-8341-4495-b8d3-4049853a894c', '2f8b14eb-3604-46c1-963a-c59096d7f221'),
('8f2803fe-d5c1-4897-9901-0ed8057d6058', '52f873a3-8341-4495-b8d3-4049853a894c', '67ff71fa-ba13-4119-a587-2aaf5d10a1e9'),
('c5975d05-8048-4751-ab41-1cde1f8d88d6', '52f873a3-8341-4495-b8d3-4049853a894c', '734a58ba-d390-4cc8-b59b-ea53a7e505e2'),
('2993d6b2-bb7e-4082-bec5-aec0f9b9f72b', '52f873a3-8341-4495-b8d3-4049853a894c', '0f940f01-0727-4244-8667-6ce3f8272ee1'),
('b65a32cd-f9b9-43c6-9177-e2198acdeba3', '52f873a3-8341-4495-b8d3-4049853a894c', 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2'),
('9aa1a783-e5a8-4a96-88db-34a7dbaaebab', '52f873a3-8341-4495-b8d3-4049853a894c', 'b762413a-393d-4caf-b184-549a3615d1e8'),
('4b7514c7-450e-4fb3-8f36-b9d7df846015', '52f873a3-8341-4495-b8d3-4049853a894c', '3d62eb40-b618-43f0-89d5-08a4408d2ab6'),
('66a7c98a-7ddf-4b40-a2ad-922f514cc3be', '52f873a3-8341-4495-b8d3-4049853a894c', 'd310a5ac-ae6c-4e37-b10a-4521f6e79113'),
('1495255c-bc16-4699-a264-160745a388a1', '67ff71fa-ba13-4119-a587-2aaf5d10a1e9', '0f940f01-0727-4244-8667-6ce3f8272ee1'),
('83190f16-1e65-4b8b-bb24-226526fae497', '67ff71fa-ba13-4119-a587-2aaf5d10a1e9', 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2'),
('6680256c-d7ab-40d7-b29e-d0c84a104a3e', '67ff71fa-ba13-4119-a587-2aaf5d10a1e9', '3d62eb40-b618-43f0-89d5-08a4408d2ab6'),
('f219116c-0dee-42fe-8d92-952bd2a93778', '67ff71fa-ba13-4119-a587-2aaf5d10a1e9', 'd310a5ac-ae6c-4e37-b10a-4521f6e79113'),
('6c706607-89d6-4125-bc1a-590c4709a44f', '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '79042567-0542-4e76-ba69-0ce30dc28492'),
('72a11996-53e9-42ea-ac9d-62812cd23563', '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '52f873a3-8341-4495-b8d3-4049853a894c'),
('08e5b026-0cf1-4b59-8060-17d4f9adfbe1', '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '0f940f01-0727-4244-8667-6ce3f8272ee1'),
('af02e61b-b08d-48cd-998d-bc6e420961f2', '734a58ba-d390-4cc8-b59b-ea53a7e505e2', 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2'),
('b33aa525-e98b-41ed-a09b-cb7814989601', '734a58ba-d390-4cc8-b59b-ea53a7e505e2', 'b762413a-393d-4caf-b184-549a3615d1e8'),
('6b607584-e619-4984-ae2c-3de5c166ea26', '734a58ba-d390-4cc8-b59b-ea53a7e505e2', '3d62eb40-b618-43f0-89d5-08a4408d2ab6'),
('63567990-609a-478a-8d39-4d1c5e03bbbf', '734a58ba-d390-4cc8-b59b-ea53a7e505e2', 'd310a5ac-ae6c-4e37-b10a-4521f6e79113'),
('19259d49-71a9-41e8-a520-3887f9817d78', '0f940f01-0727-4244-8667-6ce3f8272ee1', '2f8b14eb-3604-46c1-963a-c59096d7f221'),
('15a646cf-0e92-459e-b54b-2d41faae3ce2', '0f940f01-0727-4244-8667-6ce3f8272ee1', '79042567-0542-4e76-ba69-0ce30dc28492'),
('caf52503-16b0-490d-92fe-d3ee4a000c7d', '0f940f01-0727-4244-8667-6ce3f8272ee1', 'b762413a-393d-4caf-b184-549a3615d1e8'),
('eaaf5983-06b3-4e28-86a1-87c1a95e101f', '0f940f01-0727-4244-8667-6ce3f8272ee1', '3d62eb40-b618-43f0-89d5-08a4408d2ab6'),
('8740c027-73d2-4e4b-9a1c-79101ebc6891', '0f940f01-0727-4244-8667-6ce3f8272ee1', 'd310a5ac-ae6c-4e37-b10a-4521f6e79113'),
('809efa25-ec38-45b6-acdf-ca5bb1cac8e2', 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '79042567-0542-4e76-ba69-0ce30dc28492'),
('e4cc6d25-b31b-4496-9a03-dcfa340a1f5b', 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '52f873a3-8341-4495-b8d3-4049853a894c'),
('98a18279-0289-4f4f-bd47-ab242f5c33ab', 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '734a58ba-d390-4cc8-b59b-ea53a7e505e2'),
('a7c8aa89-9245-4788-a6ef-2be62c7c79f7', 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '0f940f01-0727-4244-8667-6ce3f8272ee1'),
('5541ec15-d7bc-46e7-b23f-f52d068df976', 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', '3d62eb40-b618-43f0-89d5-08a4408d2ab6'),
('e5cb1037-559e-4dc8-afeb-3d474f2ac24f', 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2', 'd310a5ac-ae6c-4e37-b10a-4521f6e79113'),
('4d806d68-2867-4ef7-80e6-3975b0c350a1', 'b762413a-393d-4caf-b184-549a3615d1e8', '2f8b14eb-3604-46c1-963a-c59096d7f221'),
('8a56035d-cd74-444d-83b8-8677a4a19a25', 'b762413a-393d-4caf-b184-549a3615d1e8', '52f873a3-8341-4495-b8d3-4049853a894c'),
('ef137d88-474f-4a70-916d-0af86139648a', 'b762413a-393d-4caf-b184-549a3615d1e8', '0f940f01-0727-4244-8667-6ce3f8272ee1'),
('1d4ff79b-e440-4683-88ee-30c24f9d9351', '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '52f873a3-8341-4495-b8d3-4049853a894c'),
('e3eb4c92-e232-40be-9a50-8484b7e8af36', '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '67ff71fa-ba13-4119-a587-2aaf5d10a1e9'),
('0200ee0c-1341-44e1-affd-cfe62d72a435', '3d62eb40-b618-43f0-89d5-08a4408d2ab6', '0f940f01-0727-4244-8667-6ce3f8272ee1'),
('6f1baebb-3082-4fb9-a6cc-731c3cf83241', '3d62eb40-b618-43f0-89d5-08a4408d2ab6', 'b762413a-393d-4caf-b184-549a3615d1e8'),
('ad2021d7-7462-49a2-9044-3c5ce50c8259', '3d62eb40-b618-43f0-89d5-08a4408d2ab6', 'd310a5ac-ae6c-4e37-b10a-4521f6e79113'),
('60909609-048c-4bd8-a817-487541a4aad0', 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '2f8b14eb-3604-46c1-963a-c59096d7f221'),
('71e25cd3-2827-4f8a-929a-116362260e0a', 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '67ff71fa-ba13-4119-a587-2aaf5d10a1e9'),
('654eb158-741d-4375-bb47-6606ede25b1b', 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', '0f940f01-0727-4244-8667-6ce3f8272ee1'),
('96679e9e-5f52-43a5-a6af-870e13607c20', 'd310a5ac-ae6c-4e37-b10a-4521f6e79113', 'fffbfe8f-b931-47c0-b37a-8d3365dd23c2');

-- Consulta 1: Nome, média e autor dos livros com média <= 3 estrelas publicados no Brasil
SELECT title, avg_rating, authorlabel
FROM book_avg_rating NATURAL JOIN book_author NATURAL JOIN country
WHERE avg_rating <= 3 AND ctrylabel = 'Brazil';

-- Consulta 2: Nomes e autor dos livros com maior rating
SELECT title, authorlabel
FROM book_avg_rating NATURAL JOIN book_author
WHERE avg_rating = (SELECT MAX(avg_rating) FROM book_avg_rating);

-- Consulta 3: Usernames dos usuários com mais de 1 rating e review combinados
SELECT username
FROM goodreadsuser NATURAL JOIN rating NATURAL JOIN review
GROUP BY username
HAVING COUNT(rtgcode) + COUNT(rvwcode) > 5;

-- Consulta 4: Nomes autores com mais livros publicados
SELECT authorlabel
FROM book_author
GROUP BY authorlabel
HAVING COUNT(DISTINCT isbn13) = (SELECT MAX(numero_de_livros) AS max_livros_por_autor
                                FROM (SELECT COUNT(DISTINCT isbn13) AS numero_de_livros
                                      FROM book_author
                                      GROUP BY authorlabel) as livros_por_autor);

-- Consulta 5: Nome dos usuários que têm salvo pelo menos os mesmos livros que Mariana Silva e a soma entre
-- a quantidade de pessoas seguidas por ela e que elas seguem
SELECT username, seguindo+seguidores AS soma_conexões
FROM goodreadsuser NATURAL JOIN user_follows as ext_user
WHERE username <> 'Mariana Silva' AND NOT EXISTS (SELECT isbn13
                                                 FROM bookshelfbook
                                                 WHERE usercode = (SELECT DISTINCT usercode FROM goodreadsuser
                                                                  WHERE username = 'Mariana Silva')
     															  AND isbn13 NOT IN (SELECT DISTINCT isbn13
                                                                                    FROM bookshelfbook
                                                                                    WHERE usercode = ext_user.usercode));

-- Consulta 6: Nomes dos gêneros literários com mais livros registrados
SELECT gendlabel
FROM book NATURAL JOIN hasgender NATURAL JOIN gender
GROUP BY gendlabel
HAVING COUNT(DISTINCT isbn13) = (SELECT MAX(numero_de_livros)
                                FROM (SELECT COUNT(DISTINCT isbn13) AS numero_de_livros
                                     FROM book NATURAL JOIN hasgender NATURAL JOIN gender
                                     GROUP BY gendlabel) AS livros_por_genero);

-- Consulta 7: Nomes dos usuários que escreveram mais reviews e o a quantidade de seguidores deles
SELECT username, seguidores
FROM goodreadsuser NATURAL JOIN review NATURAL JOIN user_follows
GROUP BY usercode, seguidores
HAVING COUNT(DISTINCT text) = (SELECT MAX(numero_de_reviews)
                                FROM (SELECT COUNT(DISTINCT text) AS numero_de_reviews
                                     FROM goodreadsuser NATURAL JOIN review
                                     GROUP BY usercode) AS reviews_por_user);

-- Consulta 8: Nomes dos usuários que leram mais livros e o número de pessoas que eles seguem
SELECT username, seguindo
FROM goodreadsuser NATURAL JOIN bookshelfbook NATURAL JOIN user_follows
WHERE bookstatus = 'Read'
GROUP BY usercode, seguindo
HAVING COUNT(DISTINCT isbn13) = (SELECT MAX(numero_de_livros_lidos)
                                FROM (SELECT COUNT(DISTINCT isbn13) AS numero_de_livros_lidos
                                     FROM goodreadsuser NATURAL JOIN bookshelfbook
                                     WHERE bookstatus = 'Read'
                                     GROUP BY usercode) AS livros_lidos_por_user);

-- Consulta 9: Dado o código do usuário, devolve seu gênero literário favorito
SELECT gendlabel
FROM bookshelfbook NATURAL JOIN hasgender NATURAL JOIN gender
WHERE usercode = '1992904f-6a40-4fcc-9e18-3c85e2598654'
GROUP BY gendlabel
HAVING COUNT(gendlabel) = (SELECT MAX(numero_generos)
                                FROM (SELECT COUNT(gendlabel) AS numero_generos
                                     FROM bookshelfbook NATURAL JOIN hasgender NATURAL JOIN gender
                                     WHERE usercode = '1992904f-6a40-4fcc-9e18-3c85e2598654'
                                     GROUP BY gendlabel) AS generos_do_user);

-- Consulta 10: Nome dos autores que possuem pelo menos dois livros com rating médio acima de 4
SELECT authorlabel
FROM book_avg_rating NATURAL JOIN book_author
WHERE avg_rating >= 4
GROUP BY authorlabel
HAVING COUNT(DISTINCT isbn13) > 1;