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