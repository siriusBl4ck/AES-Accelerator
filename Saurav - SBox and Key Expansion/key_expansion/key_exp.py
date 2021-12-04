file = open("key_exp128.v", 'w')

s = """
module key_exp128(
    input [127:0] short_key,
    output [127:0] round_keys [10:0]
);

"""

rounds = 11
N = 4

for i in range(rounds):
    if (i < N):
        s += "assign W_" + str(i) + " = short_key[]"