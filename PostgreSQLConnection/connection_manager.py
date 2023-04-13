import psycopg2
from sqlalchemy import create_engine

def create_psycopg2_connection(database, user, password, host, port):
    connection = psycopg2.connect(
        database=database,
        user=user,
        password=password,
        host=host,
        port=port
    )
    return connection

def create_sqlalchemy_engine(database, user, password, host, port):
    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{database}')
    return engine