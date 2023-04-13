import pandas as pd
import random
import os

from DataGenerator.Country import generate_countries
from DataGenerator.SqlInsertInto import SqlInsertInto
from DataGenerator.generators import generate_guid, generate_follower_guids
from DataGenerator.Genre import generate_genres
from DataGenerator.FakeData import genre_names, countries
from DataGenerator.GoodReadsUser import generate_goodreads_users
from DataGenerator.BookStatus import generate_book_status

NUMBER_OF_PEOPLE_TO_GENERATE = 100
NUMBER_OF_BOOKS_TO_GET_FROM_DATASET = 100

def current_dir_path():
    current_file_path = os.path.abspath(__file__)
    current_file_dir = os.path.dirname(current_file_path)
    return current_file_dir

def get_sample_from_dataset(dataset_path, quantity):
    df = pd.read_csv(dataset_path, on_bad_lines='skip')  # Lê o arquivo csv pulando as linhas que tiverem algum problema
    pd.set_option('display.max_columns', None)  # Configura o pandas para exibir todas as colunas
    random_sample = df.sample(quantity)  # Pega 10 linhas aleatórias do dataset
    return random_sample

def generate_txt_file(file_name, tables_texts):
    with open(file_name, 'w') as f:
        for table_text in tables_texts:
            f.write(table_text)
            f.write('\n\n')

def generate_sql_insertions():
    dataset_path = current_dir_path() + '/books.csv'  # Caminho do arquivo csv
    random_sample = get_sample_from_dataset(dataset_path, NUMBER_OF_BOOKS_TO_GET_FROM_DATASET)  # Pega 10 linhas aleatórias do dataset

    ############################################
    # GERA AS TABELAS RELACIONADAS AOS LIVROS
    ############################################
    language_table = SqlInsertInto('Language', ['LangLabel', 'LangCode'])
    publisher_table = SqlInsertInto('Publisher', ['PubLabel', 'PubCode'])
    country_table = SqlInsertInto('Country', ['CtryLabel', 'CtryCode'])
    author_table = SqlInsertInto('Author', ['AuthorLabel', 'AuthorCode'])
    genre_table = SqlInsertInto('Gender', ['GendLabel', 'GendCode'])
    book_table = SqlInsertInto('Book', ['ISBN13', 'Title', 'PageCount', 'RatingCount', 'ReviewCount', 'PublishingDate',
                                          'CtryCode', 'PubCode', 'LangCode'])
    hasgender_table = SqlInsertInto('HasGender', ['HasGendCode', 'ISBN13', 'GendCode'])
    writtenby_table = SqlInsertInto('WrittenBy', ['WrittenByCode', 'ISBN13', 'AuthorCode'])


    book_genres = generate_genres(genre_names)
    for genre in book_genres:
        genre_table.add_values([genre.name, genre.guid])

    book_countries = generate_countries(countries)
    for country in book_countries:
        country_table.add_values([country.name, country.guid])

    for index, row in random_sample.iterrows():
        language_guid = generate_guid()
        publisher_guid = generate_guid()
        #country_guid = generate_guid()
        author_guid = generate_guid()
        hasgender_guid = generate_guid()
        writtenby_guid = generate_guid()

        language_table.add_values([row['language_code'], language_guid])
        #country_table.add_values([row['language_code'], country_guid])
        publisher_table.add_values([row['publisher'], publisher_guid])
        author_table.add_values([row['authors'], author_guid])

        random_gender = random.choice(book_genres)
        random_country = random.choice(book_countries)
        imperial_date = row['publication_date'].split('/')
        american_date = f'{imperial_date[1]}/{imperial_date[0]}/{imperial_date[2]}'
        book_table.add_values([row['isbn13'], row['title'], row['  num_pages'], 0, 0, american_date,
                               random_country.guid, publisher_guid, language_guid])
        hasgender_table.add_values([hasgender_guid, row['isbn13'], random_gender.guid])
        writtenby_table.add_values([writtenby_guid, row['isbn13'], author_guid])

    ############################################
    # GERA AS TABELAS RELACIONADAS A USUÁRIOS
    ############################################
    goodreads_users_list = generate_goodreads_users(NUMBER_OF_PEOPLE_TO_GENERATE, random_sample)
    goodreads_user_table = SqlInsertInto('GoodreadsUser', ['UserCode', 'Age', 'UserName', 'Sex', 'Email'])
    rating_table = SqlInsertInto('Rating', ['RtgCode', 'NumberOfStars', 'UserCode', 'ISBN13'])
    review_table = SqlInsertInto('Review', ['RvwCode', 'Text', 'UserCode', 'ISBN13'])
    bookshelfbook_table = SqlInsertInto('BookshelfBook', ['BookshelfBookCode', 'BookStatus', 'UserCode', 'ISBN13'])
    follows_table = SqlInsertInto('Follows', ['FlwCode', 'UserACode', 'UserBCode'])

    for goodreads_user in goodreads_users_list:
        goodreads_user_table.add_values([goodreads_user.guid, goodreads_user.age, goodreads_user.username,
                                        goodreads_user.sex, goodreads_user.email])

        for rating in goodreads_user.ratings:
            rating_table.add_values([rating.guid, rating.value, goodreads_user.guid, rating.book_guid])

        for review in goodreads_user.reviews:
            review_table.add_values([review.guid, review.text, goodreads_user.guid, review.book_guid])

        follower_guids = generate_follower_guids(goodreads_user, goodreads_users_list)
        for follower_guid in follower_guids:
            follows_table.add_values([generate_guid(), goodreads_user.guid, follower_guid])

        book_statuses = generate_book_status(random_sample)
        for book_status in book_statuses:
            bookshelfbook_table.add_values([book_status.guid, book_status.status, goodreads_user.guid, book_status.book_guid])

    ############################################
    # GERA O .TXT DAS TABELAS
    ############################################
    tables_texts = [
        language_table.generate_insert_into(),
        publisher_table.generate_insert_into(),
        country_table.generate_insert_into(),
        author_table.generate_insert_into(),
        genre_table.generate_insert_into(),
        book_table.generate_insert_into(),
        hasgender_table.generate_insert_into(),
        writtenby_table.generate_insert_into(),
        goodreads_user_table.generate_insert_into(),
        rating_table.generate_insert_into(),
        review_table.generate_insert_into(),
        bookshelfbook_table.generate_insert_into(),
        follows_table.generate_insert_into()
    ]


    # generate .txt file
    generate_txt_file('teste.txt', tables_texts)





