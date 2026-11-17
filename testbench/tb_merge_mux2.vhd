library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_merge_mux2 is
end entity;

architecture test of tb_merge_mux2 is
    signal sel  : std_logic := '0';
    signal d0   : std_logic_vector(7 downto 0) := x"00";
    signal d1   : std_logic_vector(7 downto 0) := x"00";
    signal dout : std_logic_vector(7 downto 0);
begin
    uut: entity work.mux2
        generic map (
            WIDTH => 8
        )
        port map (
            sel  => sel,
            d0   => d0,
            d1   => d1,
            dout => dout
        );

    process
    begin
        d0 <= x"12";
        d1 <= x"A5";

        sel <= '0';
        wait for 10 ns;
        assert dout = x"12" report "Erro: mux deveria selecionar d0" severity error;

        sel <= '1';
        wait for 10 ns;
        assert dout = x"A5" report "Erro: mux deveria selecionar d1" severity error;

        d0 <= x"FF";
        d1 <= x"00";
        sel <= '0';
        wait for 10 ns;
        assert dout = x"FF" report "Erro apos alterar d0" severity error;

        report "Todos os testes do multiplexador foram concluidos!" severity note;
        wait;
    end process;
end architecture;
