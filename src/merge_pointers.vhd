library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ponteiros i, j , k

entity pointer_reg is
    generic (
        
       VALOR_MAX  : integer := 8
    );
    port (
        clk      : in  std_logic;   -- tudo atualiza na subida
        reset    : in  std_logic;   --  volta a 0

        load_en  : in  std_logic;   -- carregue load_val nesse clock
        load_val : in  integer;     -- valor que vai ser carregado

        inc_en   : in  std_logic;   -- some 1 nesse clock

        q        : out integer range 0 to VALOR_MAX   
    );
end entity;

architecture Behavioral of pointer_reg is

   
    signal valor : integer range 0 to VALOR_MAX := 0;

begin

    --so vai reagir na subida do clock
    process(clk)
    begin
        if rising_edge(clk) then

         
            if reset = '1' then
                -- reseta o ponteiro
                valor <= 0;

            elsif load_en = '1' then
                -- carrega valor de fora 
                valor <= load_val;

            elsif inc_en = '1' then
                -- incrementa em 1
                valor <= valor + 1;

            end if;
            -- se nada eh verdade eh feito o hold
        end if;
    end process;

    -- saida 
    q <= valor;

end architecture;