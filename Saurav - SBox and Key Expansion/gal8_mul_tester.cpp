#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>
#include <iomanip>

std::string uint8_to_hex_string(uint8_t v) {
  std::stringstream ss;

  ss << std::hex << std::setfill('0');

  ss << std::hex << std::setw(2) << static_cast<int>(v);

  return ss.str();
}

/* Add two numbers in the GF(2^8) finite field */
uint8_t gadd(uint8_t a, uint8_t b) {
	return a ^ b;
}

/* Multiply two numbers in the GF(2^8) finite field defined 
 * by the polynomial x^8 + x^4 + x^3 + x + 1 = 0
 * using the Russian Peasant Multiplication algorithm
 * (the other way being to do carry-less multiplication followed by a modular reduction)
 */
uint8_t gmul(uint8_t a, uint8_t b) {
	uint8_t p = 0; /* the product of the multiplication */
	while (a && b) {
            if (b & 1) /* if b is odd, then add the corresponding a to p (final product = sum of all a's corresponding to odd b's) */
                p ^= a; /* since we're in GF(2^m), addition is an XOR */

            if (a & 0x80) /* GF modulo: if a >= 128, then it will overflow when shifted left, so reduce */
                a = (a << 1) ^ 0x11b; /* XOR with the primitive polynomial x^8 + x^4 + x^3 + x + 1 (0b1_0001_1011) – you can change it but it must be irreducible */
            else
                a <<= 1; /* equivalent to a*2 */
            b >>= 1; /* equivalent to b // 2 */
	}
	return p;
}

int main(){
    std::ifstream testbench_init;
    std::ofstream testbench_final;
    std::string line;

    testbench_init.open("tb_init");
    testbench_final.open("tb_final");

    if (testbench_init.is_open() && testbench_final.is_open()){
        while (std::getline (testbench_init,line)){
            uint8_t a, b;
            sscanf(line.c_str(), "%hhu %hhu", &a, &b);
            uint8_t res = gmul(a, b);

            testbench_final << uint8_to_hex_string(a) << " " << uint8_to_hex_string(b) << " " << uint8_to_hex_string(res) << "\n";
        }
        testbench_init.close();
        testbench_final.close();
    }
}