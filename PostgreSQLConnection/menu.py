from PostgreSQLConnection.query_generator import *

menu_options = [
    "---------------------------------------------------------------",
    "Digite o comando à esquerda para rodar a ação correspondente:",
    "---------------------------------------------------------------",
    "1 -> Nome, média e autor dos livros com média <= 3 estrelas publicados em um país (input)",
    "2 -> Nome e autor dos livros com maior rating",
    "3 -> Usernames dos usuários com mais de 1 rating e review combinados",
    "4 -> Nomes autores com mais livros publicados",
    "5 -> Nome dos usuários que têm salvo pelo menos os mesmos livros que eveevans6 e a soma entre"
    "a quantidade de pessoas seguidas por ela e que elas seguem",
    "6 -> Nomes dos gêneros literários com mais livros registrados",
    "7 -> Nomes dos usuários que escreveram mais reviews e o número de seguidores",
    "8 -> Nomes dos usuários que leram mais livros e o número de pessoas que eles seguem",
    "9 -> Dado o nome do usuário, devolve seu gênero literário favorito",
    "10 -> Nome dos autores que possuem pelo menos um livros com rating médio acima, abaixo ou igual a um valor inputado",
    "11 -> Rodar query que dispara o gatilho",
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
            get_country_good_rated_books(engine)
            show_return_message()
        case "2":
            get_best_rated_books(engine)
            show_return_message()
        case "3":
            get_users_with_more_than_one_reaction(engine)
            show_return_message()
        case "4":
            get_authors_that_published_most_books(engine)
            show_return_message()
        case "5":
            get_users_with_at_least_the_same_books_as(engine)
            show_return_message()
        case "6":
            get_genres_with_most_books(engine)
            show_return_message()
        case "7":
            get_users_with_most_reviews(engine)
            show_return_message()
        case "8":
            get_users_that_read_most_books(engine)
            show_return_message()
        case "9":
            get_favorite_genre_by_usercode(engine)
            show_return_message()
        case "10":
            get_authors_with_inputed_rating(engine)
            show_return_message()
        case "11":
            run_trigger(engine)
            show_return_message()
        case "sair":
            print("Saindo do programa...")
        case _:
            print("Comando inválido")


def show_return_message():
    print("\nPressione qualquer tecla para voltar ao menu inicial")
    input()