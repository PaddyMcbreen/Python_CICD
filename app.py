import sqlite3
import random
import subprocess
from database import init_db, save_score

# Give scripts required permissions:
subprocess.run(["chmod +x ./scripts/permissions.sh"], shell=True)
subprocess.run(["./scripts/permissions.sh"], shell=True)

DATABASE = 'scores.db'

def get_db():
    conn = sqlite3.connect(DATABASE)
    return conn

def play_game():
    number_to_guess = random.randint(1, 100)
    attempts = 0

    print("Welcome to the Number Guessing Game!")
    print("I have selected a number between 1 and 100. Try to guess it!")

    while True:
        guess = int(input("Enter your guess: "))
        attempts += 1

        if guess < number_to_guess:
            print("Too low! Try again.")
        elif guess > number_to_guess:
            print("Too high! Try again.")
        else:
            print(f"Congratulations! You've guessed the number in {attempts} attempts.")
            save_score(attempts)
            
            again = str(input("Would you like to play again?: (y/n) ")).strip().lower()
            if again == "y":
                print("Great! Here we go again")
                subprocess.run(["./scripts/again_app.sh"], shell=True)
            else:
                print("Thats too bad! Bye now")
            break

if __name__ == '__main__':
    init_db()
    play_game()
