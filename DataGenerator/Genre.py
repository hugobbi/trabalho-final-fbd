from DataGenerator.generators import generate_guid

# create a class that holds names
class Genre:
    def __init__(self, genre):
        self.name = genre
        self.guid = generate_guid()

def generate_genres(genre_names):
    genres = []
    for genre_name in genre_names:
        genres.append(Genre(genre_name))
    return genres