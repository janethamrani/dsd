--Source: NerdyDave on Youtube - Getting Started With VHDL on Windows (GHDL & GTKWave)
library ieee;
use ieee.std_logic_1164.all;

entity assignment1 is
	port
	(
		a: in std_ulogic;
		b: in std_ulogic;
		o: out std_ulogic;
		c: out std_ulogic
		
	);
	
end assignment1;

architecture behave of assignment1 is
begin
	o <= a xor b;
	c <= a and b;
end behave;
