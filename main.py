import pandas as pd
from DataGenerator.InsertIntoGenerator import generate_sql_insertions
from PostgreSQLConnection.connection_manager import *
from PostgreSQLConnection.query_generator import *
from PostgreSQLConnection.menu import *

database="trabalho_fbd_etapa2"
user="postgres"
password="macaulicauquin123"
host="localhost"
port='5432'


if __name__ == '__main__':
    #generate_sql_insertions()

    #connection = create_psycopg2_connection(database, user, password, host, port) # connection using psycopg2
    engine = create_sqlalchemy_engine(database, user, password, host, port) # connection using sqlalchemy and pandas

    #query_result = run_sql_queries_with_psycopg2(connection, douglas_adams_books)
    #query_result = run_sql_query_with_pandas(engine, douglas_adams_books)

    show_menu(engine)


