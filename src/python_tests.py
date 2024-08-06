import unittest
from unittest.mock import patch
from app import play_game

class testFunc(unittest.TestCase):
    def test_func_1(self):
        pass

class pythonTests(unittest.TestCase):
    @patch('builtins.input', return_value = 50)
    def test_typeOfGuess(self, mock_input):
        # Arrange & Act
        guess = play_game()        
        # Assert
        self.assertEqual(guess, type(int), "Guess Variable is not a number")



# ---------------------------
if __name__ == "__main__":
    unittest.main()