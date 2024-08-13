import unittest
from unittest.mock import patch
from app import play_game

class testFunc(unittest.TestCase):
    def test_func_1(self):
        "This is a test function which provides no use"
        pass


class pythonAppTests(unittest.TestCase):

    # Tests the user input when taking a guess:
    @patch('builtins.input', return_value = int(50))
    @patch('random.randint', return_value=50)
    def test_correctGuess (self, mock_randint, mock_input):
        # Arrange & Act
        print("------------------------------------------------------------")
        print("                                                            ")
        print("Checks that the game passes when the num is correctly guessed")
        guess = play_game()
        print("Test Complete - Passed")   
        print("                                                            ")     
        # Assert
        mock_input.assert_called()
        mock_randint.assert_called_with(1, 100)
       # self.assertEqual(type(guess), int)

    # Tests the user input when taking a guess:
    # @patch('builtins.input', return_value = int(35))
    @patch('builtins.input', side_effect=[35, 40])
    @patch('random.randint', return_value=40)
    def test_incorrectGuess (self, mock_randint, mock_input):
        # Arrange & Act
        print("------------------------------------------------------------")
        print("                                                            ")
        print("Checks that the game respondes correcly to an incorrect guess")
        guess = play_game()
        print("Test Complete - Passed")   
        print("                                                            ")     
        # Assert
        mock_input.assert_called()
        mock_randint.assert_called_with(1, 100)


class pythonDatabaseTests(unittest.TestCase):

    #Tests the functionaility of the database:
    def test_firstDatabaseTest(self):
        print("Fill Test In")
        pass


#---------------------------
if __name__ == "__main__":
    unittest.main()
