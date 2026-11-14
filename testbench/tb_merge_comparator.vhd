
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_merge_comparator is
end entity;

architecture test of tb_merge_comparator is

    signal data_a : std_logic_vector(7 downto 0);
    signal data_b : std_logic_vector(7 downto 0);
    signal a_menor : std_logic;

begin

    uut: entity work.merge_comparator
        port map (
            data_a => data_a,
            data_b => data_b,
            a_menor => a_menor
        );

    process
    begin

        -- Teste 1
        data_a <= x"03";
        data_b <= x"07";
        wait for 10 ns;

        assert a_menor = '1'
            report "Erro no teste 1"
            severity error;

        -- Teste 2
        data_a <= x"09";
        data_b <= x"02";
        wait for 10 ns;

        assert a_menor = '0'
            report "Erro no teste 2"
            severity error;

        -- Teste 3
        data_a <= x"05";
        data_b <= x"05";
        wait for 10 ns;

        assert a_menor = '0'
            report "Erro no teste 3"
            severity error;

        -- Teste 4
        data_a <= x"01";
        data_b <= x"FF";
        wait for 10 ns;

        assert a_menor = '1'
            report "Erro no teste 4"
            severity error;

        report "Todos os testes foram concluidos!"
            severity note;

        wait;

    end process;

end architecture;
