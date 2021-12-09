// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "firmware.h"

#define STAT_ADDR 0x21000000

#define START_SIG 0x01
#define TIMEOUT 1000

#define BASE = 0x25000000;
#define KEY_BASE (BASE + 4);

#define PT_ENCR_BASE (BASE + 36);
#define PT_VALID_ADDR (BASE + 52);
#define CT_ENCR_BASE (BASE + 56);
#define CT_VALID_ADDR (BASE + 72);

#define CT_RDY_ADDR (BASE);
#define CT_ENCR_BASE (BASE+4);
#define PT_RDY_ADDR (BASE + 20);
#define PT_DECR_BASE (BASE + 24);

void send_stat(bool status);
void send_stat(bool status)
{
	if (status) {
		*((volatile int *)STAT_ADDR) = 1;
	} else {
		*((volatile int *)STAT_ADDR) = 0;
	}
}

void Writeword(int x, int addr);
void Readword(int addr);
void Write_short_key(int short_key []);
void Write_PT_Encr(int pt_encr []);
void Write_CT_Decr(int ct_decr []);
void Read_CT_Encr(int ct_encr []);
void Read_PT_Decr(int ct_encr []);

void Writeword(int x, int addr)
{
	volatile int *p = (int *)addr;
	*p = x;
}

int Readword(int addr)
{
	volatile int *p = (int *)addr;
	return (*p);
}

void Write_short_key(int short_key [], int key_len)
{
	Writeword(key_len, BASE);
	for(i=0; i<(2+(2*key_len)); i++)                             // i<key_len or something similar
	{
		Writeword(short_key[i],PT_BASE+(4*i));
	}
    Writeword(0,BASE);
}

void Write_PT_Encr(int pt_encr [])
{
	volatile int *pt_valid = (int *)PT_VALID_ADDR
	for(i=0; i<4; i++)
	{
		Writeword(pt_encr[i],PT_ENCR_BASE+(4*i));
	}
	*pt_valid = START_SIG; 
	*pt_valid = 0;
}

void Write_CT_Decr(int ct_decr [])
{
	volatile int *ct_valid = (int *)CT_VALID_ADDR;
	for(i=0; i<4; i++)
	{
		Writeword(ct_encr[i],CT_DECR_BASE+(4*i));
	}
	*ct_valid = START_SIG; 
	*ct_valid = 0;
}

/*void Read_CT_Encr(int ct_encr [])
{
	for(i=0; i<4; i++)
	{
		Readword(ct_encr[i],CT_ENCR_BASE+(4*i));
	}
}

void Read_PT_Decr(int pt_decr [])
{
	for(i=0; i<4; i++)
	{
		Readword(pt_decr[i],PT_DECR_BASE+(4*i));
	}
}*/

void AES_StartandWait(void)
{
	//volatile int *pt_valid = (int *)PT_VALID_ADDR
	//volatile int *ct_valid = (int *)CT_VALID_ADDR;
	volatile int *pt_rdy = (int *)PT_RDY_ADDR;
	volatile int *ct_rdy = (int *)CT_RDY_ADDR;

	//*pt_valid = START_SIG; 
	//*pt_valid = 0;
	//*ct_valid = START_SIG; 
	//*ct_valid = 0;

	bool rdy = false;
	int count = 0;
	while (!rdy && (count < TIMEOUT)) {
		volatile int x = (*pt_rdy); 
		volatile int y = (*ct_rdy);
		if (((x|y) & 0x01) == 1) rdy = true;
		count ++;
	}
	if (count == TIMEOUT) {
		print_str("TIMED OUT: did not get a 'ready' signal back from AES!");
	}
}

void hello(void)
{
	int i, key_len;
	int short_key[8], pt_encr[4], ct_encr[4], ct_decr[4], pt_decr[4];
    
	short_key[0] = 0x2b7e1516;
    short_key[1] = 0x28aed2a6;
	short_key[2] = 0xabf71588;
	short_key[3] = 0x09cf4f3c;

    pt_encr[0] = 0x3243f6a8;
	pt_encr[1] = 0x885a308d;
	pt_encr[2] = 0x313198a2;
	pt_encr[3] = 0xe0370734;
 
    key_len = 1;
    
	Write_short_key(short_key,key_len);
    Write_PT_Encr(pt_encr);
	AES_StartandWait();
	
	for(i=0; i<4; i++)
	{
		Readword(ct_encr[i],CT_ENCR_BASE+(4*i));
		printdec(ct_encr[i]);
	}
    send_stat(true);
}

/*#define MULT_BASE 0x30000000
#define MULT_A (MULT_BASE + 4)
#define MULT_B (MULT_BASE + 8)
#define MULT_RES (MULT_BASE + 12)

void Mult_WriteA(int x);
void Mult_WriteB(int x);
void Mult_StartAndWait(void);
int Mult_GetResult(void);

void Mult_WriteA(int x)
{
	volatile int *p = (int *)MULT_A;
	*p = x;
}

void Mult_WriteB(int x)
{
	volatile int *p = (int *)MULT_B;
	*p = x;
}

int Mult_GetResult(void)
{
	volatile int *p = (int *)MULT_RES;
	return (*p);
}

void Mult_StartAndWait(void)
{
	volatile int *p = (int *)MULT_BASE;
	*p = START_SIG; 
	*p = 0;
	bool rdy = false;
	int count = 0;
	while (!rdy && (count < TIMEOUT)) {
		volatile int x = (*p); // read from MULT_BASE
		if ((x & 0x01) == 1) rdy = true;
		count ++;
	}
	if (count == TIMEOUT) {
		print_str("TIMED OUT: did not get a 'rdy' signal back!");
	}
}*/