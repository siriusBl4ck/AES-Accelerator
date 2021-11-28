
###
# EXPLANATION
# Run the following loop 8 times (once per bit). It is OK to stop when a or b is zero before an iteration:
#    1. If the rightmost bit of b is set, exclusive OR the product p by the value of a. This is polynomial addition.
#    2. Shift b one bit to the right, discarding the rightmost bit, and making the leftmost bit have a value of zero. This divides the polynomial by x, discarding the x0 term.
#    3. Keep track of whether the leftmost bit of a is set to one and call this value carry.
#    4. Shift a one bit to the left, discarding the leftmost bit, and making the new rightmost bit zero. This multiplies the polynomial by x, but we still need to take account of carry which represented the coefficient of x7.
#    5. If carry had a value of one, exclusive or a with the hexadecimal number 0x1b (00011011 in binary). 0x1b corresponds to the irreducible polynomial with the high term eliminated. Conceptually, the high term of the irreducible polynomial and carry add modulo 2 to 0.
# p now has the product
# 7 6 5 4 3 2 1 0
# Source: Wikipedia
###
a = int(input())
b = int(input())

a_b = bin(a)[2:]
b_b = bin(b)[2:]

while (len(a_b) != 8):
    a_b = '0' + a_b

while (len(b_b) != 8):
    b_b = '0' + b_b

print(a_b, b_b)

p = "00000000"

def xor8(a, b):
    c = ""
    for i in range(len(a)):
        if (a[i] == b[i]):
            c = c + "0"
        else:
            c = c + "1"
    return c

for i in range(8):
    if b_b[7-i] == '1':
        p = xor8(p, a_b)

    carry = a_b[0]
    a_b = a_b[1:] + '0'
    
    if (carry == '1'):
        a_b = xor8(a_b, "00011011")

print(int(p, 2))