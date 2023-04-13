import random
from DataGenerator.generators import generate_guid
from DataGenerator.FakeData import book_status_choices

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