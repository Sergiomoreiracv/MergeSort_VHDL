library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_merge_control is
end entity;

architecture test of tb_merge_control is
    signal clk         : std_logic := '0';
    signal reset       : std_logic := '0';
    signal start       : std_logic := '0';
    signal done        : std_logic;
    signal busy        : std_logic;
    signal rd_addr     : integer range 0 to 4 := 0;
    signal read_bank   : std_logic;
    signal read_addr_a : integer range 0 to 4;
    signal read_addr_b : integer range 0 to 4;
    signal write_a     : std_logic;
    signal write_b     : std_logic;
    signal write_en    : std_logic;
    signal write_addr  : integer range 0 to 4;
    signal select_data : std_logic;
    signal a_menor     : std_logic := '1';
begin
    clk <= not clk after 5 ns;

    uut: entity work.merge_control
        generic map (
            NUM_ELEMENTOS => 4
        )
        port map (
            clk         => clk,
            reset       => reset,
            start       => start,
            done        => done,
            busy        => busy,
            rd_addr     => rd_addr,
            read_bank   => read_bank,
            read_addr_a => read_addr_a,
            read_addr_b => read_addr_b,
            write_a     => write_a,
            write_b     => write_b,
            write_en    => write_en,
            write_addr  => write_addr,
            select_data => select_data,
            a_menor     => a_menor
        );

    process
        variable ciclos : integer;
    begin
        reset <= '1';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';

        assert busy = '0' report "busy deveria ser 0 no estado IDLE" severity error;
        assert done = '0' report "done deveria ser 0 apos reset" severity error;

        start <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        start <= '0';
        assert busy = '1' report "busy deveria subir apos start" severity error;

        wait until rising_edge(clk);
        wait for 1 ns;
        wait until rising_edge(clk);
        wait for 1 ns;

        assert read_bank = '0' report "origem inicial deveria ser banco A" severity error;
        assert read_addr_a = 0 report "ponteiro esquerdo inicial incorreto" severity error;
        assert read_addr_b = 1 report "ponteiro direito inicial incorreto" severity error;
        assert write_en = '1' report "merge deveria habilitar escrita" severity error;
        assert write_addr = 0 report "endereco de escrita inicial incorreto" severity error;
        assert select_data = '0' report "a_menor deveria selecionar o dado esquerdo" severity error;
        assert write_a = '0' report "destino inicial incorreto" severity error;
        assert write_b = '1' report "destino inicial deveria ser banco B" severity error;

        wait for 1 ns;
        a_menor <= '0';
        ciclos := 0;
        while done /= '1' and ciclos < 100 loop
            wait until rising_edge(clk);
            wait for 1 ns;
            ciclos := ciclos + 1;
        end loop;

        assert done = '1' report "Timeout esperando a FSM concluir" severity failure;
        assert busy = '0' report "busy deveria ser 0 no estado DONE" severity error;
        assert read_bank = '0' report "resultado final deveria estar no banco A para NUM_ELEMENTOS = 4" severity error;

        report "Todos os testes da unidade de controle foram concluidos!" severity note;
        wait;
    end process;
end architecture;
