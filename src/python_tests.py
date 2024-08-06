import unittest
from app import play_game
from unittest.mock import patch

class testFunc(unittest.TestCase):
    def test_func_1(self):
        pass

class pythonTests(unittest.TestCase):
    @patch('app.input', return_value='50')  # Mock input to return '50'
    def test_typeOfGuess(self, mock_input):
        # Arrange & Act
        guess = play_game()
        # Assert
        self.assertIsInstance(guess, int)



# ---------------------------
if __name__ == "__main__":
    unittest.main()