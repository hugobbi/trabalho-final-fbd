import pandas as pd
import random
import os
from DataGenerator import *

from SqlInsertInto import SqlInsertInto
from generators import generate_guid, generate_follower_guids
from Genre import generate_genres
from FakeData import genre_names
from GoodReadsUser import generate_goodreads_users
from BookStatus import generate_book_status

NUMBER_OF_PEOPLE_TO_GENERATE = 10
NUMBER_OF_BOOKS_TO_GET_FROM_DATASET = 10

def current_dir_path():
    current_file_path = os.path.abspath(__file__)
    current_file_dir = os.path.dirname(current_file_path)
    return current_file_dir

def get_sampe_from_dataset(dataset_path, quantity):
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
    random_sample = get_sampe_from_dataset(dataset_path, NUMBER_OF_BOOKS_TO_GET_FROM_DATASET)  # Pega 10 linhas aleatórias do dataset

    ############################################
    # GERA AS TABELAS RELACIONADAS AOS LIVROS
    ############################################
    language_table = SqlInsertInto('Language', ['Label', 'Code'])
    publisher_table = SqlInsertInto('Publisher', ['Label', 'Code'])
    country_table = SqlInsertInto('Country', ['Label', 'Code'])
    author_table = SqlInsertInto('Author', ['Label', 'Code'])
    gender_table = SqlInsertInto('Gender', ['Label', 'Code'])
    book_table = SqlInsertInto('Book', ['ISBN13', 'Title', 'PageCount', 'RatingCount', 'ReviewCount', 'PublishingDate',
                                          'fk_Country_Code', 'fk_Publisher_Code', 'fk_Language_Code'])
    hasgender_table = SqlInsertInto('HasGender', ['Code', 'fk_Book_ISBN13', 'fk_Gender_Code'])
    writtenby_table = SqlInsertInto('WrittenBy', ['Code', 'fk_Book_ISBN13', 'fk_Author_Code'])


    book_genres = generate_genres(genre_names)

    for index, row in random_sample.iterrows():
        language_guid = generate_guid()
        publisher_guid = generate_guid()
        country_guid = generate_guid()
        author_guid = generate_guid()
        gender_guid = generate_guid()
        hasgender_guid = generate_guid()
        writtenby_guid = generate_guid()

        language_table.add_values([row['language_code'], language_guid])
        country_table.add_values([row['language_code'], country_guid])
        publisher_table.add_values([row['publisher'], publisher_guid])
        author_table.add_values([row['authors'], author_guid])
        random_gender = random.choice(book_genres)
        gender_table.add_values([random_gender.name, random_gender.guid])
        book_table.add_values([str(row['isbn13']), row['title'], str(random.randint(100, 500)), str(row['ratings_count']),
                               str(row['text_reviews_count']), row['publication_date'], country_guid, publisher_guid,
                               language_guid])
        hasgender_table.add_values([hasgender_guid, str(row['isbn13']), gender_guid])
        writtenby_table.add_values([writtenby_guid, str(row['isbn13']), author_guid])

    ############################################
    # GERA AS TABELAS RELACIONADAS A USUÁRIOS
    ############################################
    goodreads_users_list = generate_goodreads_users(NUMBER_OF_PEOPLE_TO_GENERATE, random_sample)
    goodreads_user_table = SqlInsertInto('GoodreadsUser', ['Code', 'Age', 'UserName', 'Sex', 'Email'])
    rating_table = SqlInsertInto('Rating', ['Code', 'NumberOfStars', 'fk_GoodreadsUser_Code', 'fk_Book_ISBN13'])
    review_table = SqlInsertInto('Review', ['Code', 'Text', 'fk_GoodreadsUser_Code', 'fk_Book_ISBN13'])
    bookshelfbook_table = SqlInsertInto('BookshelfBook', ['Code', 'BookStatus', 'fk_GoodreadsUser_Code', 'fk_Book_ISBN13'])
    follows_table = SqlInsertInto('Follows', ['Code', 'GoodreadsUser_A_Code', 'GoodreadsUser_B_Code'])

    for goodreads_user in goodreads_users_list:
        goodreads_user_table.add_values([goodreads_user.guid, str(goodreads_user.age), goodreads_user.username,
                                        goodreads_user.sex, goodreads_user.email])

        for rating in goodreads_user.ratings:
            rating_table.add_values([rating.guid, str(rating.value), goodreads_user.guid, rating.book_guid])

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
        gender_table.generate_insert_into(),
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





