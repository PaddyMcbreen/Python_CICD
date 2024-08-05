# Add required imports when creating further tests.

# Unneccesarry fill in tests to show pytest working:
class fillInTests():

    def test_upper(self):
        self.assertEqual('foo'.upper(), 'FOO')

    def test_isupper(self):
        self.assertTrue('FOO'.isupper())
        self.assertFalse('Foo'.isupper())