from DataGenerator.generators import generate_guid

class Country:
    def __init__(self, country):
        self.name = country
        self.guid = generate_guid()

def generate_countries(countries_names):
    countries = []
    for country_name in countries_names:
        countries.append(Country(country_name))
    return countries