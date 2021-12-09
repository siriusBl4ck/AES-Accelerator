
temp:
	iverilog -c files.txt tb.v 
	./a.out
	
default_compile aes:
	@echo "Compiling all codes"
	iverilog *.v -o aes

exec: aes
	@echo "Executing.."
	./aes


