import random
from generators import generate_guid
from FakeData import people_names
from Review import generate_reviews
from Rating import generate_ratings

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


def generate_goodreads_users(quantity, dataframe):
    goodreads_users = []
    for i in range(quantity):
        goodreads_users.append(GoodReadsUser(random.choice(people_names), dataframe))
    return goodreads_users