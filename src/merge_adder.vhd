library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--  somador do mid: a = lo,  b = width || vai calcular mid e o valor inicial de j
--  somador do hi: a = lo,  b = 2 * width || vai calcular hi (2 * width eh um deslocamento de 1 bit)
entity adder is
    port (
        a   : in  integer;   
        b   : in  integer;  
        sum : out integer    
    );
end entity;

architecture Behavioral of adder is
begin

    
    sum <= a + b;

end architecture;