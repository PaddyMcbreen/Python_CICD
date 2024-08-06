# import unittest
# from unittest.mock import patch
# from app import play_game

# class testFunc(unittest.TestCase):
#     def test_func_1(self):
#         "This is a test function which provides no use"
#         pass


# class userInputTests(unittest.TestCase):
#     @patch('builtins.input', return_value = int(50))
#     def test_guessIsNum(self, mock_input):
#         # Arrange & Act
#         print("------------------------------------------------------------")
#         print("                                                            ")
#         print("Checks that the user input will work with a random integer")
#         guess = play_game()
#         print("Test Complete - Passed")   
#         print("                                                            ")     
#         # Assert
#         self.assertEqual(type(guess), int)


#     @patch('builtins.input', return_value = int("50"))
#     def test_guessIsNum2(self, mock_input):
#         # Arrange & Act
#         print("------------------------------------------------------------")
#         print("                                                            ")
#         print("Checks that the user input with convert a numbered string to an integer")
#         guess = play_game() 
#         print("Test Complete - Passed")    
#         print("                                                            ")   
#         # Assert
#         self.assertEqual(type(guess), int)


    # @patch('builtins.input', return_value = str("fifty"))
    # @unittest.expectedFailure
    # def test_UserInputStr(self, mock_input):
    #     # Arrange & Act
    #     print("------------------------------------------------------------")
    #     print("                                                            ")
    #     print("Checks that the user input will not allow strings that cannot convert to a number")
    #     guess = play_game()  
    #     print("Test Complete - Passed")   
    #     print("                                                            ")   
    #     # Assert
    #     self.assertEqual(type(guess), int)

        # CHnage in game code to prevent string from being used in input that cannot be converted to a number!!!x


# ---------------------------
# if __name__ == "__main__":
#     unittest.main()