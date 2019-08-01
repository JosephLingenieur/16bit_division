# 16bit division 
Using this Assembly script you be able to divide 16bit numbers. I used it in my microcontroller "pic16F870" 

### Example test : 30000 / 5000 

d 30000 = b01110101_00110000 = 0X75_30;
			0X75	112 * 2^8 = 29952
			0X30			  =____48 +
							  = 30000

d 5000	= b00010011_10001000 = 0X13_88

			0X13	19  * 2^8 = 4864
			0X88			  =__136 +
							  = 5000
