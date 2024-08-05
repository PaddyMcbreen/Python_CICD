import unittest
from app import play_game

class testFunc(unittest.TestCase):
    def test_func_1(self):
        pass

class pythonTests(unittest.TestCase):
    def test_zeroAttempts(self):
        # Arrange & Act
        attempts = play_game(attempts)
        # Assert
        self.assertEqual(attempts, 0, "The variable 'attempts' should start at 0.")



# ---------------------------
if __name__ == "__main__":
    unittest.main()