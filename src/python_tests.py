import unittest
from app import play_game

class testFunc(unittest.TestCase):
    def test_func_1(self):
        pass

class pythonTests(unittest.TestCase):
    def test_typeOfGuess(self):
        # Arrange & Act
        guess = play_game()
        # Assert
        self.assertEqual(guess, int)



# ---------------------------
if __name__ == "__main__":
    unittest.main()