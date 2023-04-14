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

-- PROCEDIMENTOS ARMAZENADOS ----------------------------------------------------

-- Função para incrementar o número de ratings de um livro
CREATE OR REPLACE FUNCTION increment_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE book SET ratingcount = ratingcount + 1 WHERE book.isbn13 = NEW.isbn13;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para incrementar o número de ratings de um livro
CREATE TRIGGER rating_counter
AFTER INSERT ON Rating
FOR EACH ROW
EXECUTE PROCEDURE increment_rating();

-- Função para incrementar o número de reviews de um livro
CREATE OR REPLACE FUNCTION increment_review()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE book SET reviewcount = reviewcount + 1 WHERE book.isbn13 = NEW.isbn13;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para incrementar o número de reviews de um livro
CREATE TRIGGER review_counter
AFTER INSERT ON Review
FOR EACH ROW
EXECUTE PROCEDURE increment_review();

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
HAVING COUNT(rtgcode) + COUNT(rvwcode) > 1;

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
WHERE username <> 'eveevans6' AND NOT EXISTS (SELECT isbn13
                                                 FROM bookshelfbook
                                                 WHERE usercode = (SELECT DISTINCT usercode FROM goodreadsuser
                                                                  WHERE username = 'eveevans6')
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
WHERE usercode = '20e4eff1-0147-4696-8475-915199fac0d5'
GROUP BY gendlabel
HAVING COUNT(gendlabel) = (SELECT MAX(numero_generos)
                                FROM (SELECT COUNT(gendlabel) AS numero_generos
                                     FROM bookshelfbook NATURAL JOIN hasgender NATURAL JOIN gender
                                     WHERE usercode = '20e4eff1-0147-4696-8475-915199fac0d5'
                                     GROUP BY gendlabel) AS generos_do_user);

-- Consulta 10: Nome dos autores que possuem pelo menos um livro com rating médio acima de 4
SELECT authorlabel
FROM book_avg_rating NATURAL JOIN book_author
WHERE avg_rating >= 4
GROUP BY authorlabel
HAVING COUNT(DISTINCT isbn13) >= 1;