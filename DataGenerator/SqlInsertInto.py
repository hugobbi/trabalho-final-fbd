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

        for i, value_list in enumerate(values):
            for j, value in enumerate(value_list):
                if isinstance(value, str):
                    value_list[j] = "'" + value.replace("'", "") + "'"

            values[i] = value_list

        tuple = [f"({', '.join(value)})" for value in values]
        return tuple

    def add_values(self, values):
        self.values.append(values)