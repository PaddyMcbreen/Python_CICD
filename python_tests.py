# Add required imports when creating further tests.
import python_tests

# Unneccesarry fill in tests to show pytest working:
class fillInTests():
 def test_upper():
    assert 'foo'.upper() == 'FOO'
    
 def test_isupper():
    assert 'FOO'.isupper()
    assert not 'Foo'.isupper()