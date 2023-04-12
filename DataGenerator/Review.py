import random
from FakeData import book_reviews
from generators import generate_guid

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