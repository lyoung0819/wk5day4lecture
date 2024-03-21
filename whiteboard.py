# The Hamming Distance is a measure of similarity between two strings of equal length. Complete the function so that it returns the number of differences between the two strings.

# Examples:
# a = "I like turtles"
# b = "I like turkeys"
# Result: 3

# a = "Hello World"
# b = "Hello World"
# Result: 0

#a = "espresso"
#b = "Expresso"
# Result: 2

# Notes:
# You can assume that the two inputs strings of equal length.

# case sensitive 
# hamming will only look at differences between two equal length strings
# input - two strings // output - number of differences (differences being difference in case type, length, or letters, etc)

# check if strings are of equal length (which will be the case)
# if equal
# start count at 0 
# iterate through each word in the string
    # split string by space to determine each word
# compare if each index in the word == the same as the same index in the other word
# if it does match, we do nothing, or add 0 
# if it does not match,we add 1 to a count 


def solution(a, b):
    diff_count = 0
    for word in range(len(a)):
        if a[word] != b[word]:
            diff_count += 1
    return diff_count 