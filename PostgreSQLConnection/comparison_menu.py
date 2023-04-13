from PostgreSQLConnection.query_generator import *

comparison_options = [
    "1 -> >",
    "2 -> <",
    "3 -> =",
    "4 -> >=",
    "5 -> <="
    ]

def show_comparison_menu():
    comparison_value = "loop"
    while comparison_value == "loop":
        print_comparison_menu()
        input = prompt_input()
        comparison_value = get_value(input)

    return comparison_value


def print_comparison_menu():
    print("\n")
    for option in comparison_options:
        print(option)

def prompt_input():
    return input("Digite o número do comparador desejado: ")

def get_value(input):
    match str(input):
        case "1":
            return ">"
        case "2":
            return "<"
        case "3":
            return "="
        case "4":
            return ">="
        case "5":
            return "<="
        case _:
            print("Comando inválido")
            return "loop"
