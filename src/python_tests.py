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
    def test_guessIsNum(self, mock_input):
        # Arrange & Act
        print("------------------------------------------------------------")
        print("                                                            ")
        print("Checks that the user input will work with a random integer")
        guess = play_game()
        print("Test Complete - Passed")   
        print("                                                            ")     
        # Assert
        self.assertEqual(type(guess), int)


class pythonDatabaseTests(unittest.TestCase):

    #Tests the functionaility of the database:
    def test_firstDatabaseTest(self):
        print("Fill Test In")
        pass


#---------------------------
if __name__ == "__main__":
    unittest.main()