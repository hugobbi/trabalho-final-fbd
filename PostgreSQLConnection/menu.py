from PostgreSQLConnection.query_generator import *

menu_options = [
    "---------------------------------------------------------------",
    "Digite o comando à esquerda para rodar a ação correspondente:",
    "---------------------------------------------------------------",
    "1 -> Procurar livros de um autor com uso do prompt de comando",
    "2 -> Procurar livros de acordo com a sua avaliação com o uso do prompt de comando",
    "3 -> ",
    "4 -> ",
    "5 -> ",
    "6 -> ",
    "7 -> ",
    "8 -> ",
    "9 -> ",
    "10 -> ",
    "sair -> Sair do programa",
    "---------------------------------------------------------------\n",
    ]

def show_menu(engine):
    input = 0
    while input != "sair":
        print_menu()
        input = prompt_input()
        run_menu_option(input, engine)


def print_menu():
    print("\n")
    for option in menu_options:
        print(option)

def prompt_input():
    return input("Digite o comando desejado: ")

def run_menu_option(input, engine):
    match input:
        case "1":
            get_books_with_autor_name(engine)
            show_return_message()
        case "2":
            select_rating_type(engine)
            show_return_message()
        case "3":
            print("3")
        case "4":
            print("4")
        case "5":
            print("5")
        case "6":
            print("6")
        case "7":
            print("7")
        case "8":
            print("8")
        case "9":
            print("9")
        case "10":
            print("10")
        case "sair":
            print("Saindo do programa...")
        case _:
            print("Comando inválido")


def show_return_message():
    print("\nPressione qualquer tecla para voltar ao menu inicial")
    input()