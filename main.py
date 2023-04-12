import pandas as pd
import random
import os


def current_dir_path():
    current_file_path = os.path.abspath(__file__)
    current_file_dir = os.path.dirname(current_file_path)
    return current_file_dir

# create a sql insert into class
class SqlInsertInto:
    def __init__(self, table_name, columns):
        self.table_name = table_name
        self.columns = columns
        self.values = []

    def generate_insert_into(self):
        columns = ', '.join(self.columns)
        tuple_values = self.transform_values_into_tuples(self.values)
        values = ', \n'.join(tuple_values)
        return f'INSERT INTO {self.table_name} ({columns}) VALUES \n{values};'

    def transform_values_into_tuples(self, values):
        return [f"({', '.join(value)})" for value in values]

    def add_values(self, values):
        self.values.append(values)


genre_names = [
        "Mystery/Thriller",
        "Science Fiction",
        "Fantasy",
        "Romance",
        "Historical Fiction",
        "Horror",
        "Young Adult",
        "Literary Fiction",
        "Crime/Noir",
        "Adventure",
        "Biography/Autobiography",
        "Non-Fiction",
        "Self-Help",
        "Memoir",
        "Poetry",
        "Drama/Play",
        "Comedy/Humor",
        "Western",
        "Dystopian",
        "Children's/Picture Book",
        "Paranormal/Supernatural",
        "Urban Fantasy",
        "Steampunk",
        "Contemporary Fiction",
        "Magical Realism",
        "Thriller/Suspense",
        "Espionage",
        "War/Military Fiction",
        "Women's Fiction",
        "Sports Fiction",
        "Science/Popular Science",
        "True Crime",
        "Cookbook/Culinary",
        "Travel/Adventure",
        "Art/Photography",
        "Religion/Spirituality",
        "Philosophy",
        "Psychology/Psychological Thriller",
        "LGBTQ+ Fiction",
        "Post-Apocalyptic",
        "Alternate History",
        "Cyberpunk",
        "Supernatural Romance",
        "Time Travel",
        "Cozy Mystery",
        "Folklore/Fairy Tales",
        "Graphic Novel/Comic",
        "Western Romance",
        "Short Stories/Anthology",
        "Classic Literature"
    ]


# create a class that holds names
class Genre:
    def __init__(self, genre):
        self.name = genre
        self.guid = generate_guid()


# create a function that generates random GoodReadUsers given a quantity
def generate_genres(genre_names):
    genres = []
    for genre_name in genre_names:
        genres.append(Genre(genre_name))
    return genres

class Rating:
    def __init__(self, book_guid):
        self.value = random.randint(0, 5)
        self.guid = generate_guid()
        self.book_guid = book_guid

# generate a random number of Rating objects between 0 and 30
def generate_ratings(dataframe):
    ratings = []
    for i in range(random.randint(0, 30)):
        random_isbn = str(dataframe.sample(1)['isbn13'].values[0])
        random_rating = Rating(random_isbn)
        ratings.append(random_rating)
    return ratings

book_reviews = [
    "A captivating tale with rich characters and vivid imagery. Highly recommended!",
    "An intriguing and thought-provoking read that kept me hooked from start to finish.",
    "A beautifully written book that tugs at the heartstrings. A must-read for any book lover.",
    "A thrilling page-turner with unexpected twists and turns. Couldn't put it down!",
    "A powerful and poignant story that left me deeply moved. Beautifully written and expertly crafted.",
    "An enchanting and magical book that swept me away to a different world. A true gem.",
    "A heartwarming story of love, loss, and redemption. Poignant and beautifully written.",
    "An engaging and well-paced novel with a unique and original premise. I was captivated from the first page.",
    "A beautifully written and emotionally resonant tale that will stay with me for a long time.",
    "A gripping and suspenseful read that kept me on the edge of my seat. I couldn't turn the pages fast enough!",
    "A touching and poignant exploration of the human condition. A book that will make you think and feel deeply.",
    "A mesmerizing and lyrical novel that transports readers to a different time and place. I was captivated by the prose.",
    "An epic and sweeping saga that spans generations. A masterful work of historical fiction.",
    "A witty and humorous novel that had me laughing out loud. A delightful and entertaining read.",
    "A haunting and atmospheric story that lingers in the mind long after the last page. A literary masterpiece.",
    "A thrilling and suspenseful mystery with well-drawn characters and a cleverly crafted plot. Highly recommended for fans of the genre.",
    "A heartwarming and uplifting tale of resilience and hope. A celebration of the human spirit.",
    "A thought-provoking and timely novel that tackles important social issues with sensitivity and grace. A must-read for our times.",
    "A beautifully written and evocative book that transports readers to a different era. A must-read for historical fiction enthusiasts."
]

class Review:
    def __init__(self, book_guid):
        # get random review from "book_reviews" list
        self.text = random.choice(book_reviews)
        self.guid = generate_guid()
        self.book_guid = book_guid

def generate_reviews(dataframe):
    reviews = []
    for i in range(random.randint(0, 2)):
        random_isbn = str(dataframe.sample(1)['isbn13'].values[0])
        random_review = Review(random_isbn)
        reviews.append(random_review)
    return reviews

book_status_choices = [
    "Reading",
    "Read",
    "Want To Read"
    ]

class BookStatus:
    def __init__(self, book_guid):
        self.book_guid = book_guid
        self.status = random.choice(book_status_choices)
        self.guid = generate_guid()

def generate_book_status(dataframe):
    book_statuses = []
    for i in range(random.randint(0, 5)):
        random_isbn = str(dataframe.sample(1)['isbn13'].values[0])
        random_book_status = BookStatus(random_isbn)
        book_statuses.append(random_book_status)
    return book_statuses

people_names = [
    "Alice Adams",
    "Bob Brown",
    "Charlie Chen",
    "David Davis",
    "Eve Evans",
    "Frank Franklin",
    "Grace Garcia",
    "Hank Hernandez",
    "Ivy Ingram",
    "Jack Johnson",
    "Kate King",
    "Liam Lee",
    "Mia Mitchell",
    "Nathan Nguyen",
    "Olivia Ortiz",
    "Paul Phillips",
    "Quincy Quintero",
    "Rose Rodriguez",
    "Sam Smith",
    "Tina Taylor",
    "Uma Upton",
    "Victor Vargas",
    "Wendy Williams",
    "Xander Xavier",
    "Yara Young",
    "Zane Zimmerman"
]


# create a class that holds names
class GoodReadsUser:
    def __init__(self, complete_name, dataframe):
        self.complete_name = complete_name
        self.age = random.randint(18, 100)
        self.username = self.generate_username()
        self.sex = random.choice(['M', 'F'])
        self.email = self.generate_email()
        self.guid = generate_guid()
        self.ratings = generate_ratings(dataframe)
        self.reviews = generate_reviews(dataframe)

    def generate_username(self):
        first_name, last_name = self.complete_name.split()
        random_number = random.randint(1, 100)
        return f'{first_name.lower()}{last_name.lower()}{str(random_number)}'

    def generate_email(self):
        first_name, last_name = self.complete_name.split()
        random_number = random.randint(1, 100)
        return f'{first_name.lower()}{last_name.lower()}{str(random_number)}@gmail.com'

# create a function that generates random GoodReadUsers given a quantity
def generate_goodreads_users(quantity, dataframe):
    goodreads_users = []
    for i in range(quantity):
        goodreads_users.append(GoodReadsUser(random.choice(people_names), dataframe))
    return goodreads_users


def generate_follower_guids(followed, possible_followers):
    follower_guids = []
    for follower in possible_followers:
        if random.randint(0, 1) == 1:
            if follower.guid != followed.guid:
                follower_guids.append(follower.guid)
    return follower_guids

# create a function that generates a guid
def generate_guid():
    import uuid
    return str(uuid.uuid4())

if __name__ == '__main__':
    dataset_path = current_dir_path() + '/books.csv'  # Caminho do arquivo csv
    df = pd.read_csv(dataset_path, on_bad_lines='skip')  # Lê o arquivo csv pulando as linhas que tiverem algum problema
    pd.set_option('display.max_columns', None)  # Configura o pandas para exibir todas as colunas

    random_sample = df.sample(10)  # Pega 10 linhas aleatórias do dataset

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
    goodreads_users_list = generate_goodreads_users(10, random_sample)
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

    # generate .txt file
    with open('teste.txt', 'w') as f:
        # write text on file
        f.write(language_table.generate_insert_into())
        f.write('\n\n')
        f.write(publisher_table.generate_insert_into())
        f.write('\n\n')
        f.write(country_table.generate_insert_into())
        f.write('\n\n')
        f.write(author_table.generate_insert_into())
        f.write('\n\n')
        f.write(gender_table.generate_insert_into())
        f.write('\n\n')
        f.write(book_table.generate_insert_into())
        f.write('\n\n')
        f.write(hasgender_table.generate_insert_into())
        f.write('\n\n')
        f.write(writtenby_table.generate_insert_into())
        f.write('\n\n')
        f.write(goodreads_user_table.generate_insert_into())
        f.write('\n\n')
        f.write(rating_table.generate_insert_into())
        f.write('\n\n')
        f.write(review_table.generate_insert_into())
        f.write('\n\n')
        f.write(bookshelfbook_table.generate_insert_into())
        f.write('\n\n')
        f.write(follows_table.generate_insert_into())
        f.write('\n\n')





