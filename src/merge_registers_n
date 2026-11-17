library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- registrador simples com enable de carga, nao tem a logica de incrementar + 1
-- vai ser usado para width, lo, mid, hi e src

entity reg_n is
    generic (
        -- para valor_max = 8 -> width, lo, mid, hi
        -- para valor max = 1 -> src
        VALOR_MAX : integer := 8
    );
    port (
        clk      : in  std_logic;   -- relogio
        reset    : in  std_logic;   -- reset sincrono

        load_en  : in  std_logic;   -- caarrega load_val neste clock
        load_val : in  integer;     -- valor que vai ser carregado

        q        : out integer range 0 to VALOR_MAX   -- valor atual
    );
end entity;

architecture Behavioral of reg_n is

    --   range limitado para o valor maximo
    signal valor : integer range 0 to VALOR_MAX := 0;

begin

    -- so eh ativo na subida do clock
    process(clk)
    begin
        if rising_edge(clk) then

            if reset = '1' then
                valor <= 0;

            elsif load_en = '1' then
                valor <= load_val;

            end if;
            -- se nao tem load_en o valor so eh mantido mesmo
        end if;
    end process;

    -- saida 
    q <= valor;

end architecture;