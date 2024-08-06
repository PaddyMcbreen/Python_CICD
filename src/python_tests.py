import unittest
from unittest.mock import patch
from app import play_game

class testFunc(unittest.TestCase):
    def test_func_1(self):
        pass


class userInputTests(unittest.TestCase):
    @patch('builtins.input', return_value = int(50))
    def test_guessIsNum(self, mock_input):
        # Arrange & Act
        guess = play_game()        
        # Assert
        self.assertEqual(type(guess), int)

    @patch('builtins.input', return_value = int("50"))
    def test_guessIsNum2(self, mock_input):
        # Arrange & Act
        guess = play_game()        
        # Assert
        self.assertEqual(type(guess), int)


class expectedFailureTests(unittest.TestCase):
    @patch('builtins.input', return_value = int(50))
    @unittest.expectedFailure
    def test_UserInputStr(self, mock_input):
        # Arrange & Act
        guess = play_game()        
        # Assert
        self.assertEqual(type(guess), str)



# ---------------------------
if __name__ == "__main__":
    unittest.main()