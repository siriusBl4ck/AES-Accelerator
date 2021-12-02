def twomul(a):
	 b = (a<<1);
	 if(a>=0x80):
	 	return b^(0x1b)
	 else:
	 	return b

def threemul(a):
	return (twomul(a)^a)

ans = (0x87)^twomul(0x6e)^threemul(0x46)^(0xa6)
ans = str(hex(ans))
print("0x%s%s"%(ans[len(ans)-2],ans[len(ans)-1]))
