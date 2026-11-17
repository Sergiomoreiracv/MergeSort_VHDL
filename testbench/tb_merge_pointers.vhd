library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_merge_pointers is
end entity;

architecture test of tb_merge_pointers is
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal load_en  : std_logic := '0';
    signal load_val : integer := 0;
    signal inc_en   : std_logic := '0';
    signal q        : integer range 0 to 8;
begin
    clk <= not clk after 5 ns;

    uut: entity work.pointer_reg
        generic map (
            VALOR_MAX => 8
        )
        port map (
            clk      => clk,
            reset    => reset,
            load_en  => load_en,
            load_val => load_val,
            inc_en   => inc_en,
            q        => q
        );

    process
    begin
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';
        assert q = 0 report "Erro no reset do ponteiro" severity error;

        load_val <= 5;
        load_en <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        load_en <= '0';
        assert q = 5 report "Erro no carregamento do ponteiro" severity error;

        inc_en <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        inc_en <= '0';
        assert q = 6 report "Erro na incrementacao do ponteiro" severity error;

        wait until rising_edge(clk);
        wait for 1 ns;
        assert q = 6 report "Erro no hold do ponteiro" severity error;

        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';
        assert q = 0 report "Erro no reset apos operacoes" severity error;

        report "Todos os testes do registrador de ponteiro foram concluidos!" severity note;
        wait;
    end process;
end architecture;
