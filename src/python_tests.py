import unittest
from unittest.mock import patch
from app import play_game

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


    # Tests that the game can be replayed:
    @patch('builtins.input', side_effect=[23, 86, "y", 45, "n"])
    @patch('random.randint', side_effect=[86, 45])
    def test_incorrectGuess (self, mock_randint, mock_input):
        # Arrange & Act
        print("------------------------------------------------------------")
        print("                                                            ")
        print("Checks that the game is able to be replayed")
        guess = play_game()
        guess_2 = play_game()
        print("Test Complete - Passed")   
        print("                                                            ")     
        # Assert
        mock_input.assert_called()
        mock_randint.assert_called_with(1, 100)

        mock_input.assert_called()
        mock_randint.assert_called_with(1, 100)


    # Tests the user input when taking a guess:
    @patch('builtins.input', side_effect=[35, 40, "n"])
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

#---------------------------
if __name__ == "__main__":
    unittest.main()
