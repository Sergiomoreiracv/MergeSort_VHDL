library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_merge_adder is
end entity;

architecture test of tb_merge_adder is
    signal a   : integer := 0;
    signal b   : integer := 0;
    signal sum : integer;
begin
    uut: entity work.adder
        port map (
            a   => a,
            b   => b,
            sum => sum
        );

    process
    begin
        a <= 0;
        b <= 0;
        wait for 10 ns;
        assert sum = 0 report "Erro: 0 + 0" severity error;

        a <= 3;
        b <= 5;
        wait for 10 ns;
        assert sum = 8 report "Erro: soma positiva" severity error;

        a <= 7;
        b <= 9;
        wait for 10 ns;
        assert sum = 16 report "Erro: calculo de ponteiro" severity error;

        report "Todos os testes do somador foram concluidos!" severity note;
        wait;
    end process;
end architecture;
