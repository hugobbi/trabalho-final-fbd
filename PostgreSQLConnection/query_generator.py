import pandas as pd

from PostgreSQLConnection.comparison_menu import show_comparison_menu


def run_sql_queries_with_psycopg2(connection, query):
    cursor_obj = connection.cursor()
    cursor_obj.execute(query)
    result = cursor_obj.fetchall()
    return result

def run_sql_query_with_pandas(engine, query):
    dataframe = pd.read_sql(query, engine)
    return dataframe

def get_books_with_autor_name(engine):
    author_name = input("Digite o nome do autor: ")
    author_books_query = f"\t\tSELECT Book.title, Book.pagecount \n" \
                          "\t\tFROM Author NATURAL JOIN WrittenBy NATURAL JOIN Book \n" \
                          "\t\tWHERE Author.authorlabel = '%" + f"{author_name}" + "%';"

    print(f'\nQuery:\n{author_books_query}\n')

    author_books_actual_query = f"SELECT Book.title, Book.pagecount " \
                                 "FROM Author NATURAL JOIN WrittenBy NATURAL JOIN Book " \
                                 "WHERE Author.authorlabel LIKE %s;"

    result = pd.read_sql(author_books_actual_query, con=engine, params=('%' + author_name + '%',))
    show_result_message(result)



def select_rating_type(engine):
    comparison_value = show_comparison_menu()
    rating_value = get_rating_value()

    book_rating_query = f"\t\tSELECT Book.title, AVG(numberofstars) as averagerating \n" \
                         "\t\tFROM Book NATURAL JOIN rating \n" \
                         "\t\tGROUP BY Book.isbn13 \n" \
                         "\t\tHAVING AVG(numberofstars) " + f"{comparison_value} {rating_value}" + ";"

    print(f'\nQuery:\n{book_rating_query}\n')
    book_rating_query.replace("\t", "")
    book_rating_query.replace("\n", "")

    result = run_sql_query_with_pandas(engine, book_rating_query)
    show_result_message(result)


def get_rating_value():
    rating_value = input("Digite a nota desejada: ")
    try:
        rating_value = float(rating_value)
    except ValueError:
        print("O valor digitado não é um número.")
        get_rating_value()

    return rating_value




def show_result_message(dataframe):
    print("###############################################################")
    if dataframe.empty:
        print("Nenhum resultado encontrado.")
    else:
        print(dataframe)
    print("###############################################################")


def get_brazilian_bad_rated_books(engine):
    brazil_bad_rated_books = f"\t\tSELECT title, avg_rating, authorlabel \n" \
                                "\t\tFROM book_avg_rating NATURAL JOIN book_author NATURAL JOIN country \n" \
                                "\t\tWHERE avg_rating <= 3 AND ctrylabel = 'Brazil';"

    print(f'\nQuery:\n{brazil_bad_rated_books}\n')
    brazil_bad_rated_books.replace("\t", "")
    brazil_bad_rated_books.replace("\n", "")

    result = run_sql_query_with_pandas(engine, brazil_bad_rated_books)
    show_result_message(result)

def get_best_rated_books(engine):
    best_rated_books = f"\t\tSELECT title, authorlabel \n" \
                        "\t\tFROM book_avg_rating NATURAL JOIN book_author \n" \
                        "\t\tWHERE avg_rating = (SELECT MAX(avg_rating) FROM book_avg_rating);"

    print(f'\nQuery:\n{best_rated_books}\n')
    best_rated_books.replace("\t", "")
    best_rated_books.replace("\n", "")

    result = run_sql_query_with_pandas(engine, best_rated_books)
    show_result_message(result)

def get_users_with_more_than_one_reaction(engine):
    users_with_more_than_five_reactions = f"\t\tSELECT username \n" \
                                           "\t\tFROM goodreadsuser NATURAL JOIN rating NATURAL JOIN review \n" \
                                           "\t\tGROUP BY username \n" \
                                           "\t\tHAVING COUNT(rtgcode) + COUNT(rvwcode) > 1;"

    print(f'\nQuery:\n{users_with_more_than_five_reactions}\n')
    users_with_more_than_five_reactions.replace("\t", "")
    users_with_more_than_five_reactions.replace("\n", "")

    result = run_sql_query_with_pandas(engine, users_with_more_than_five_reactions)
    show_result_message(result)

def get_authors_that_published_most_books(engine):
    authors_that_published_most_books = f"\t\tSELECT authorlabel \n" \
                                          "\t\tFROM book_author \n" \
                                          "\t\tGROUP BY authorlabel \n" \
                                          "\t\tHAVING COUNT(DISTINCT isbn13) = (SELECT MAX(numero_de_livros) AS max_livros_por_autor \n" \
                                                            "\t\t\t\t\t\t\t\t\t\tFROM (SELECT COUNT(DISTINCT isbn13) AS numero_de_livros \n" \
                                                            "\t\t\t\t\t\t\t\t\t\t\t\tFROM book_author \n" \
                                                            "\t\t\t\t\t\t\t\t\t\t\t\tGROUP BY authorlabel) as livros_por_autor);"

    print(f'\nQuery:\n{authors_that_published_most_books}\n')
    authors_that_published_most_books.replace("\t", "")
    authors_that_published_most_books.replace("\n", "")

    result = run_sql_query_with_pandas(engine, authors_that_published_most_books)
    show_result_message(result)

def get_users_with_at_least_the_same_books_as(engine):
    users_with_at_least_the_same_books_as = f"\t\tSELECT username, seguindo+seguidores AS soma_conexões \n" \
                                          "\t\tFROM goodreadsuser NATURAL JOIN user_follows as ext_user \n" \
                                          "\t\tWHERE username <> 'Mariana Silva' AND NOT EXISTS (SELECT isbn13 \n" \
                                                                            "\t\t\t\t\t\t\t\t\t\tFROM bookshelfbook \n" \
                                                                            "\t\t\t\t\t\t\t\t\t\t\t\tWHERE usercode = (SELECT DISTINCT usercode FROM goodreadsuser \n" \
                                                                            "\t\t\t\t\t\t\t\t\t\t\t\tWHERE username = 'Mariana Silva') \n" \
                                                                            "\t\t\t\t\t\t\t\t\t\t\t\tAND isbn13 NOT IN (SELECT DISTINCT isbn13 \n" \
                                                                            "\t\t\t\t\t\t\t\t\t\t\t\tFROM bookshelfbook \n" \
                                                                            "\t\t\t\t\t\t\t\t\t\t\t\tWHERE usercode = ext_user.usercode));"

    print(f'\nQuery:\n{users_with_at_least_the_same_books_as}\n')
    users_with_at_least_the_same_books_as.replace("\t", "")
    users_with_at_least_the_same_books_as.replace("\n", "")

    result = run_sql_query_with_pandas(engine, users_with_at_least_the_same_books_as)
    show_result_message(result)

def get_genres_with_most_books(engine):
    genres_with_most_books = f"\t\tSELECT gendlabel \n" \
                              "\t\tFROM book NATURAL JOIN hasgender NATURAL JOIN gender \n" \
                              "\t\tGROUP BY gendlabel \n" \
                              "\t\tHAVING COUNT(DISTINCT isbn13) = (SELECT MAX(numero_de_livros) \n" \
                                                                            "\t\t\t\t\t\t\t\t\t\tFROM (SELECT COUNT(DISTINCT isbn13) AS numero_de_livros \n" \
                                                                            "\t\t\t\t\t\t\t\t\t\t\t\tFROM book NATURAL JOIN hasgender NATURAL JOIN gender \n" \
                                                                            "\t\t\t\t\t\t\t\t\t\t\t\tGROUP BY gendlabel) AS livros_por_genero);"

    print(f'\nQuery:\n{genres_with_most_books}\n')
    genres_with_most_books.replace("\t", "")
    genres_with_most_books.replace("\n", "")

    result = run_sql_query_with_pandas(engine, genres_with_most_books)
    show_result_message(result)

def get_users_with_most_reviews(engine):
    users_with_most_reviews = f"\t\tSELECT username, seguidores \n" \
                              "\t\tFROM goodreadsuser NATURAL JOIN review NATURAL JOIN user_follows \n" \
                              "\t\tGROUP BY usercode, seguidores \n" \
                              "\t\tHAVING COUNT(DISTINCT text) = (SELECT MAX(numero_de_reviews) \n" \
                                                                            "\t\t\t\t\t\t\t\t\t\tFROM (SELECT COUNT(DISTINCT text) AS numero_de_reviews \n" \
                                                                            "\t\t\t\t\t\t\t\t\t\t\t\tFROM goodreadsuser NATURAL JOIN review \n" \
                                                                            "\t\t\t\t\t\t\t\t\t\t\t\tGROUP BY usercode) AS reviews_por_user);"

    print(f'\nQuery:\n{users_with_most_reviews}\n')
    users_with_most_reviews.replace("\t", "")
    users_with_most_reviews.replace("\n", "")

    result = run_sql_query_with_pandas(engine, users_with_most_reviews)
    show_result_message(result)

def get_users_that_read_most_books(engine):
    users_that_read_most_books = f"\t\tSELECT username, seguindo \n" \
                                   "\t\tFROM goodreadsuser NATURAL JOIN bookshelfbook NATURAL JOIN user_follows \n" \
                                    "\t\tWHERE bookstatus = 'Read' \n" \
                                    "\t\tGROUP BY usercode, seguindo \n" \
                                    "\t\tHAVING COUNT(DISTINCT isbn13) = (SELECT MAX(numero_de_livros_lidos) \n" \
                                                        "\t\t\t\t\t\t\t\t\t\tFROM (SELECT COUNT(DISTINCT isbn13) AS numero_de_livros_lidos \n" \
                                                        "\t\t\t\t\t\t\t\t\t\t\t\tFROM goodreadsuser NATURAL JOIN bookshelfbook \n" \
                                                         "\t\t\t\t\t\t\t\t\t\t\t\tWHERE bookstatus = 'Read' \n" \
                                                         "\t\t\t\t\t\t\t\t\t\t\t\tGROUP BY usercode) AS livros_lidos_por_user);"

    print(f'\nQuery:\n{users_that_read_most_books}\n')
    users_that_read_most_books.replace("\t", "")
    users_that_read_most_books.replace("\n", "")

    result = run_sql_query_with_pandas(engine, users_that_read_most_books)
    show_result_message(result)

def get_favorite_genre_by_usercode(engine):
    users_favorite_genre = f"\t\tSELECT gendlabel \n" \
                            "\t\tFROM bookshelfbook NATURAL JOIN hasgender NATURAL JOIN gender \n" \
                            "\t\tWHERE usercode = '1992904f-6a40-4fcc-9e18-3c85e2598654' \n" \
                            "\t\tGROUP BY gendlabel \n" \
                            "\t\tHAVING COUNT(gendlabel) = (SELECT MAX(numero_generos) \n" \
                                            "\t\t\t\t\t\t\t\t\t\tFROM (SELECT COUNT(gendlabel) AS numero_generos \n" \
                                            "\t\t\t\t\t\t\t\t\t\t\t\tWHERE usercode = '1992904f-6a40-4fcc-9e18-3c85e2598654' \n" \
                                            "\t\t\t\t\t\t\t\t\t\t\t\tGROUP BY gendlabel) AS generos_do_user);"

    print(f'\nQuery:\n{users_favorite_genre}\n')
    users_favorite_genre.replace("\t", "")
    users_favorite_genre.replace("\n", "")

    result = run_sql_query_with_pandas(engine, users_favorite_genre)
    show_result_message(result)

def get_authors_with_rating_bigger_than_four(engine):
    authors_with_rating_bigger_than_four = f"\t\tSELECT authorlabel \n" \
                                            "\t\tFROM book_avg_rating NATURAL JOIN book_author \n" \
                                            "\t\tWHERE avg_rating >= 4 \n" \
                                            "\t\tGROUP BY authorlabel \n" \
                                            "\t\tHAVING COUNT(DISTINCT isbn13) > 1;"

    print(f'\nQuery:\n{authors_with_rating_bigger_than_four}\n')
    authors_with_rating_bigger_than_four.replace("\t", "")
    authors_with_rating_bigger_than_four.replace("\n", "")

    result = run_sql_query_with_pandas(engine, authors_with_rating_bigger_than_four)
    show_result_message(result)