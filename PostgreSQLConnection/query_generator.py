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

def show_result_message(dataframe):
    print("###############################################################")
    if dataframe.empty:
        print("Nenhum resultado encontrado.")
    else:
        print(dataframe)
    print("###############################################################")


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







