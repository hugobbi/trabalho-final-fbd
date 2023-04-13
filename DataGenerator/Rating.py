import random
from DataGenerator.generators import generate_guid

class Rating:
    def __init__(self, book_guid):
        self.value = random.randint(0, 5)
        self.guid = generate_guid()
        self.book_guid = book_guid

def generate_ratings(dataframe):
    ratings = []
    for i in range(random.randint(0, 30)):
        random_isbn = str(dataframe.sample(1)['isbn13'].values[0])
        random_rating = Rating(random_isbn)
        ratings.append(random_rating)
    return ratings