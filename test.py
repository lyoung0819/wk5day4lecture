from unittest import TestCase, main

from whiteboard import solution

class MatchTestCase(TestCase):
    def test_example_one(self):
        self.assertEqual(solution("I like turtles","I like turkeys"), 3)
    def test_example_two(self):
        self.assertEqual(solution("Hello World","Hello World"), 0)
    def test_example_three(self):
        self.assertEqual(solution("espresso","Expresso"),2)
    def test_big_ol_strings(self):
        self.assertEqual(solution("old father, old artificer","of my soul the uncreated "), 24)



if __name__ == '__main__':
    main()