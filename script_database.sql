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
	AuthorLabel varchar(80) NOT NULL
);

CREATE TABLE Gender (
	GendCode uuid PRIMARY KEY,
    GendLabel varchar(80) NOT NULL
);

CREATE TABLE Book (
    ISBN13 bigint PRIMARY KEY NOT NULL,
    Title varchar(80) NOT NULL,
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

INSERT INTO Language (LangLabel, LangCode) VALUES 
('Portuguese', '421d9103-2857-4934-9094-4d528d1d39e9'),
('English', '6a1a7c0b-f418-4e2b-a256-42cf4d2db0d9'),
('Spanish', '66b75abf-b5e8-4bd0-922a-0d2e589c9165');

INSERT INTO Publisher (PubLabel, PubCode) VALUES 
('Harper', 'be490906-1f4d-40eb-8b61-cf81972a3439'),
('Penguin Classics', '233d244e-23f8-4895-a484-9e5ba673e1f2'),
('Punto de Lectura', '9775aee2-5a04-41f2-b9d1-4c0d9e9ac22b');

INSERT INTO Country (CtryLabel, CtryCode) VALUES 
('Brazil', 'e02eb86f-bffb-49bb-9555-9be2989ec3b1'),
('England', 'b9b5b4c3-8037-4855-9901-5652d9b4b898'),
('Spain', '202b80a5-5781-4866-9203-a9485244e804');

INSERT INTO Author (AuthorLabel, AuthorCode) VALUES 
('Douglas Adams', '9a396da0-c99e-43aa-aaea-062df8029a37'),
('Rosa Montero', '3b9eb624-f02f-44d6-bde5-28a552226a9c'),
('J.R.R. Tolkien', '7d5c97c3-80b9-4162-b383-f6adf9cab669');

INSERT INTO Gender (GendLabel, GendCode) VALUES 
('Science-Fiction', 'f06f44ec-4d7e-46fa-8107-b80ff0b66864'),
('Fantasy', '44705a00-1535-4a25-8025-9935a71afd6c'),
('Drama', '3ffa1ac8-a825-4611-85a4-092af189dae7');

INSERT INTO Book (ISBN13, Title, PageCount, RatingCount, ReviewCount, PublishingDate, CtryCode, PubCode, LangCode) VALUES 
(872205851, 'The Lord of the Rings- 3 volumes set (The Lord of the Rings  #1-3)', 1438, 232, 9, '06/01/2005', 'b9b5b4c3-8037-4855-9901-5652d9b4b898', '233d244e-23f8-4895-a484-9e5ba673e1f2', '6a1a7c0b-f418-4e2b-a256-42cf4d2db0d9'),
(1400052920, 'The Hitchhikers Guide to the Galaxy (Hitchhikers Guide to the Galaxy  #1)', 215, 4930, 460, '08/03/2004', 'b9b5b4c3-8037-4855-9901-5652d9b4b898', 'be490906-1f4d-40eb-8b61-cf81972a3439', '6a1a7c0b-f418-4e2b-a256-42cf4d2db0d9'),
(8466318771, 'Historia del rey transparente', 592, 1266, 90, '09/01/2006', '202b80a5-5781-4866-9203-a9485244e804', '9775aee2-5a04-41f2-b9d1-4c0d9e9ac22b', '66b75abf-b5e8-4bd0-922a-0d2e589c9165');

INSERT INTO GoodreadsUser (UserCode, Age, UserName, Sex, Email) VALUES 
('8877961c-e1a6-43b5-bef2-9ead81a71303', 22, 'Mariana Silva', 'F', 'marianasilva@hotmail.com'),
('0968bff8-1697-4604-939e-7fa2055cefdd', 16, 'Julia Clemente', 'F', 'juliaclemente@hotmail.com'),
('1992904f-6a40-4fcc-9e18-3c85e2598654', 54, 'Ricardo Sales', 'M', 'ricardosales@hotmail.com');

INSERT INTO Rating (RtgCode, NumberOfStars, UserCode, ISBN13) VALUES 
('936308d9-7e79-44bd-8f12-fbe0f58404bb', 4, '8877961c-e1a6-43b5-bef2-9ead81a71303', 872205851),
('a4e9752d-cae4-43a2-94a4-ce2fce5f970b', 2, '0968bff8-1697-4604-939e-7fa2055cefdd', 1400052920),
('341c58e6-35c6-4b6f-8753-8cdb03d81b2b', 5, '1992904f-6a40-4fcc-9e18-3c85e2598654', 8466318771);

INSERT INTO Review (RvwCode, Text, UserCode, ISBN13) VALUES 
('936308d9-7e79-44bd-8f12-fbe0f58404bb', 'Gostei :D', '8877961c-e1a6-43b5-bef2-9ead81a71303', 872205851),
('a4e9752d-cae4-43a2-94a4-ce2fce5f970b', 'Mais ou menos', '0968bff8-1697-4604-939e-7fa2055cefdd', 1400052920),
('341c58e6-35c6-4b6f-8753-8cdb03d81b2b', 'Mudou minha vida', '1992904f-6a40-4fcc-9e18-3c85e2598654', 8466318771);

INSERT INTO HasGender (HasGendCode, ISBN13, GendCode) VALUES 
('288930d0-5314-465e-878a-ed507f0e70ec', '872205851', '44705a00-1535-4a25-8025-9935a71afd6c'),
('16ac6562-3507-497f-9b80-8513378c5ddf', '872205851', '3ffa1ac8-a825-4611-85a4-092af189dae7'),
('1840b07a-0da0-490b-bf87-acba9fcfcb2d', '1400052920', 'f06f44ec-4d7e-46fa-8107-b80ff0b66864'),
('3f3d4dd1-051b-436f-a57f-90a038ff56ff', '1400052920', '44705a00-1535-4a25-8025-9935a71afd6c'),
('e464a739-8286-46dd-a19f-f0a27f67d120', '1400052920', '3ffa1ac8-a825-4611-85a4-092af189dae7'),
('2998a7b7-8bfc-4f1d-808d-b03b39df1bb9', '8466318771', '3ffa1ac8-a825-4611-85a4-092af189dae7');

INSERT INTO WrittenBy (WrittenByCode, ISBN13, AuthorCode) VALUES 
('3f416e70-efa4-4c8b-9580-c3516f21e140', '872205851', '7d5c97c3-80b9-4162-b383-f6adf9cab669'),
('aa1fc303-fd99-4ebc-9e87-e6c707e4cfbd', '1400052920', '9a396da0-c99e-43aa-aaea-062df8029a37'),
('6c388ee0-5353-41a9-a56a-d6e852c39b05', '8466318771', '3b9eb624-f02f-44d6-bde5-28a552226a9c');

INSERT INTO BookshelfBook (BookshelfBookCode, BookStatus, UserCode, ISBN13) VALUES 
('ddc9d795-b950-40e5-989c-4771ed21fa71', 'Reading', '8877961c-e1a6-43b5-bef2-9ead81a71303', 872205851),
('c408869c-b074-4f7f-9632-26638fc48b42', 'To Read', '8877961c-e1a6-43b5-bef2-9ead81a71303', 1400052920),
('3caa9e65-c79f-4055-af9f-c4320befcc70', 'Read', '1992904f-6a40-4fcc-9e18-3c85e2598654', 872205851),
('3caa9e65-c79f-4055-af9f-c4350befdd70', 'Read', '1992904f-6a40-4fcc-9e18-3c85e2598654', 1400052920),
('3cbb6e65-c79f-4155-af9f-c4350befdd70', 'Read', '1992904f-6a40-4fcc-9e18-3c85e2598654', 8466318771);

INSERT INTO Follows (FlwCode, UserACode, UserBCode) VALUES 
('e76e05bb-0e6e-40cd-8e3f-50547c5ae410' ,'8877961c-e1a6-43b5-bef2-9ead81a71303', '0968bff8-1697-4604-939e-7fa2055cefdd'),
('17b40b51-0006-453a-920a-ec181b356bd7', '8877961c-e1a6-43b5-bef2-9ead81a71303', '1992904f-6a40-4fcc-9e18-3c85e2598654'),
('3f033c50-17b3-4efa-8984-e2f54af8fa5d', '0968bff8-1697-4604-939e-7fa2055cefdd', '1992904f-6a40-4fcc-9e18-3c85e2598654');

-- Visão contendo um livro e seu autor
create view book_author AS
SELECT book.isbn13, author.authorlabel
from book natural join writtenby natural join author;

-- Visão contendo informações sobre o livro e a média de estrelas dele
create view book_avg_rating AS
select book.isbn13, book.title, book.ctrycode, book.langcode, book.pubcode, book.ratingcount, avg(rating.numberofstars) as avg_rating
from book natural join rating
GROUP by book.isbn13, book.title, book.ctrycode, book.langcode, book.pubcode, book.ratingcount;

-- Visão contendo usuário e número de pessoas seguindo e que seguem ele
create view user_follows as
select usercode, seguindo, seguidores
from (Select usercode, count(userbcode) as seguidores
      from goodreadsuser left join follows on usercode = userbcode
      group by usercode, userbcode) as seguidores_tab 
      join 
      (Select usercode, count(useracode) as seguindo
      from goodreadsuser left join follows on usercode = useracode
      group by usercode, useracode) as seguindo_tab 
      using(usercode);
      
-- Consulta 1: nome dos livros com mais de 4 estrelas de média publicados no Brasil e a média das suas estrelas e seu autor
select title, avg_rating, authorlabel
from book_avg_rating natural join book_author NATURAL JOIN country 
WHERE avg_rating >= 4 and ctrylabel = 'Brazil';

-- Consulta 2: nomes dos livros com maior rating e seus autores
SELECT title, authorlabel
from book_avg_rating natural join book_author
where avg_rating = (SELECT max(avg_rating) from book_avg_rating);

-- Consulta 3: usernames dos usuários com mais de 5 ratings e reviews combinados
SELECT username
from goodreadsuser natural join rating natural join review
group by username
having count(rtgcode) + COUNT(rvwcode) > 5;

-- Consulta 4: nomes autores com mais livros publicados
select authorlabel
from book_author
group by authorlabel
having count(DISTINCT isbn13) = (SELECT MAX(numero_de_livros) AS max_livros_por_autor
                                FROM (SELECT COUNT(DISTINCT isbn13) AS numero_de_livros
                                      FROM book_author
                                      GROUP BY authorlabel) as livros_por_autor);



                                
-- Consulta 5: nome dos usuários que tem salvado pelo menos os mesmos livros que Mariana Silva e a soma entre
-- a quantidade de pessoas seguidas por ela e que elas seguem
select username, seguindo+seguidores as soma_conexões
from goodreadsuser natural join user_follows as ext_user 
WHERE username <> 'Mariana Silva' AND not EXISTS (select isbn13
                                                 from bookshelfbook
                                                 where usercode = (select DISTINCT usercode from goodreadsuser
                                                                  where username = 'Mariana Silva')
     															  AND isbn13 not in (SELECT DISTINCT isbn13
                                                                                    from bookshelfbook
                                                                                    where usercode = ext_user.usercode));

-- Consulta 6: nomes dos gêneros literários com mais livros registrados
select gendlabel
from book natural join hasgender natural join gender
GROUP by gendlabel
having count(DISTINCT isbn13) = (SELECT max(numero_de_livros)
                                from (select count(DISTINCT isbn13) as numero_de_livros
                                     from book natural join hasgender natural join gender
                                     group by gendlabel) as livros_por_genero);
                                     
-- Consulta 7: nomes dos usuários que escreveram mais reviews e o número de seguidores
select username, seguidores
from goodreadsuser natural join review natural join user_follows
GROUP by usercode, seguidores
having count(DISTINCT text) = (SELECT max(numero_de_reviews)
                                from (select count(DISTINCT text) as numero_de_reviews
                                     from goodreadsuser natural join review
                                     group by usercode) as reviews_por_user);
                                     
-- Consulta 8: nomes dos usuários que leram mais livros e o número de pessoas que eles seguem
select username, seguindo
from goodreadsuser natural join bookshelfbook natural join user_follows
where bookstatus = 'Read'
GROUP by usercode, seguindo
having count(DISTINCT isbn13) = (SELECT max(numero_de_livros_lidos)
                                from (select count(DISTINCT isbn13) as numero_de_livros_lidos
                                     from goodreadsuser natural join bookshelfbook
                                     where bookstatus = 'Read'
                                     GROUP by usercode) as livros_lidos_por_user);

-- Consulta 9: dado o código do usuário, devolve seu gênero literário favorito
select gendlabel
from bookshelfbook natural join hasgender natural join gender
where usercode = '1992904f-6a40-4fcc-9e18-3c85e2598654'
group by gendlabel
having count(gendlabel) = (SELECT max(numero_generos)
                                from (select count(gendlabel) as numero_generos
                                     from bookshelfbook natural join hasgender natural join gender
                                     where usercode = '1992904f-6a40-4fcc-9e18-3c85e2598654'
                                     GROUP by gendlabel) as generos_do_user);
                                     
-- Consulta 10: nome dos autores que possuem pelo menos dois livros com rating médio acima de 4
select authorlabel
from book_avg_rating natural join book_author
where avg_rating >= 4
GROUP by authorlabel
having count(DISTINCT isbn13) > 1

