import unittest
from app import play_game
from unittest.mock import mock

class testFunc(unittest.TestCase):
    def test_func_1(self):
        pass

class pythonTests(unittest.TestCase):
    def test_typeOfGuess(self):
        # Arrange & Act
        guess = play_game(5)
        if type(guess) is int:
            pass
        else:
            self.fail("Guess variable is not a number")
        # Assert
        # self.assertIsInstance(guess, int)



# ---------------------------
if __name__ == "__main__":
    unittest.main()