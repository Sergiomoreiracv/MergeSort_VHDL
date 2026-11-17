library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_merge_registers is
end entity;

architecture test of tb_merge_registers is
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal load_en  : std_logic := '0';
    signal load_val : integer := 0;
    signal q        : integer range 0 to 8;
begin
    clk <= not clk after 5 ns;

    uut: entity work.reg_n
        generic map (
            VALOR_MAX => 8
        )
        port map (
            clk      => clk,
            reset    => reset,
            load_en  => load_en,
            load_val => load_val,
            q        => q
        );

    process
    begin
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';
        assert q = 0 report "Erro no reset do registrador" severity error;

        load_val <= 3;
        load_en <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert q = 3 report "Erro na carga do registrador" severity error;

        load_en <= '0';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert q = 3 report "Erro no hold do registrador" severity error;

        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';
        assert q = 0 report "Erro no segundo reset" severity error;

        report "Todos os testes do registrador generico foram concluidos!" severity note;
        wait;
    end process;
end architecture;
