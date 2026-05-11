from pyoctra import octra

# dir(octra)

octra.hello()

dp = octra.DPair(1, 2)

s = octra.SVector(3)
s[0] = "1"
s[1] = "2"
s[2] = "3"
# s[3] = "4"  # <- Gets index out of bounds error
