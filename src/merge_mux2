library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- multiplexador 2:1 de largura generica

-- para o mux de x       | WIDTH = 8    sel = src       d0 = ax         d1 = bx
-- para o mux de y       | WIDTH = 8    sel = src       d0 = ay         d1 = by
-- para o mux de escrita | WIDTH = 8    sel = pega_esq  d0 = y          d1 = x
-- para o mux de saida   | WIDTH = 64   sel = src       d0 = todos A    d1 = todos B
entity mux2 is
    generic (
        -- 8 para um valor || 64 para o vetor inteiro dos 8 valores
        WIDTH : integer := 8
    );
    port (
        sel  : in  std_logic;                            -- escolhe d0 ou d1 (seletor)
        d0   : in  std_logic_vector(WIDTH-1 downto 0);   -- d0 escolhido
        d1   : in  std_logic_vector(WIDTH-1 downto 0);   -- d1 escolhido
        dout : out std_logic_vector(WIDTH-1 downto 0)    -- saida
    );
end entity;

architecture Behavioral of mux2 is
begin

   
    -- dout recebe d1 quando sel eh 1, senao recebe d0

    dout <= d1 when sel = '1' else d0;

end architecture;