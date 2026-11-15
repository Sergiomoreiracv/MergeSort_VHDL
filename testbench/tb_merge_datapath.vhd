
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_merge_datapath is
end entity;

architecture Behavioral of tb_merge_datapath is

    constant NUM_ELEMENTOS : integer := 8;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';

    signal load_a : std_logic := '0';
    signal load_b : std_logic := '0';
    signal load_data : std_logic_vector(NUM_ELEMENTOS*8-1 downto 0);

    signal read_bank : std_logic := '0';
    signal read_addr_a : integer range 0 to NUM_ELEMENTOS := 0;
    signal read_addr_b : integer range 0 to NUM_ELEMENTOS := 0;

    signal write_a : std_logic := '0';
    signal write_b : std_logic := '0';
    signal write_en : std_logic := '0';
    signal write_addr : integer range 0 to NUM_ELEMENTOS := 0;

    signal select_data : std_logic := '0';

    signal data_a : std_logic_vector(7 downto 0);
    signal data_b : std_logic_vector(7 downto 0);
    signal a_menor : std_logic;

begin

    -- Instancia do datapath
    uut: entity work.merge_datapath
        generic map(
            NUM_ELEMENTOS => NUM_ELEMENTOS
        )
        port map(
            clk => clk,
            reset => reset,

            load_a => load_a,
            load_b => load_b,
            load_data => load_data,

            read_bank => read_bank,
            read_addr_a => read_addr_a,
            read_addr_b => read_addr_b,

            write_a => write_a,
            write_b => write_b,
            write_en => write_en,
            write_addr => write_addr,
            select_data => select_data,

            data_a => data_a,
            data_b => data_b,
            a_menor => a_menor
        );

    -- Geracao do clock: periodo de 10 ns
    clk <= not clk after 5 ns;

    -- Processo de testes
    process
    begin

        report "INICIANDO TESTES DO MERGE DATAPATH"
            severity note;

        ------------------------------------------------
        -- TESTE 1: RESET
        ------------------------------------------------

        reset <= '1';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait for 1 ns;

        reset <= '0';
        wait until rising_edge(clk);
        wait for 1 ns;

        report "RESET CONCLUIDO" severity note;

        ------------------------------------------------
        -- TESTE 2: CARREGAR BANCO A
        ------------------------------------------------

        load_data <= x"0102030405060708";
        load_a <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;

        load_a <= '0';

        report "BANCO A CARREGADO" severity note;

        ------------------------------------------------
        -- TESTE 3: CARREGAR BANCO B
        ------------------------------------------------

        load_data <= x"090A0B0C0D0E0F10";
        load_b <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;

        load_b <= '0';

        report "BANCO B CARREGADO" severity note;

        ------------------------------------------------
        -- TESTE 4: LEITURA DO BANCO A
        ------------------------------------------------

        read_bank <= '0';
        read_addr_a <= 0;
        read_addr_b <= 1;

        wait for 1 ns;

        assert data_a = x"01"
            report "ERRO: leitura A[0]"
            severity failure;

        assert data_b = x"02"
            report "ERRO: leitura A[1]"
            severity failure;

        assert a_menor = '1'
            report "ERRO: comparacao do banco A"
            severity failure;

        report "LEITURA E COMPARACAO DO BANCO A OK"
            severity note;

        ------------------------------------------------
        -- TESTE 5: LEITURA DO BANCO B
        ------------------------------------------------

        read_bank <= '1';

        wait for 1 ns;

        assert data_a = x"09"
            report "ERRO: leitura B[0]"
            severity failure;

        assert data_b = x"0A"
            report "ERRO: leitura B[1]"
            severity failure;

        assert a_menor = '1'
            report "ERRO: comparacao do banco B"
            severity failure;

        report "LEITURA E COMPARACAO DO BANCO B OK"
            severity note;

        ------------------------------------------------
        -- TESTE 6: ESCRITA DE data_a NO BANCO A
        ------------------------------------------------

        read_bank <= '0';
        read_addr_a <= 0;
        select_data <= '0';

        wait for 1 ns;

        write_addr <= 2;
        write_a <= '1';
        write_en <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;

        write_en <= '0';
        write_a <= '0';

        -- Verificar o valor escrito
        read_addr_a <= 2;

        wait for 1 ns;

        assert data_a = x"01"
            report "ERRO: escrita de data_a no banco A"
            severity failure;

        report "ESCRITA NO BANCO A OK"
            severity note;

        ------------------------------------------------
        -- TESTE 7: ESCRITA DE data_b NO BANCO B
        ------------------------------------------------

        read_bank <= '1';
        read_addr_b <= 1;
        select_data <= '1';

        wait for 1 ns;

        write_addr <= 2;
        write_b <= '1';
        write_en <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;

        write_en <= '0';
        write_b <= '0';

        -- Verificar o valor escrito
        read_addr_a <= 2;

        wait for 1 ns;

        assert data_a = x"0A"
            report "ERRO: escrita de data_b no banco B"
            severity failure;

        report "ESCRITA NO BANCO B OK"
            severity note;

        ------------------------------------------------
        -- FINALIZACAO
        ------------------------------------------------

        report "================================"
            severity note;

        report "TODOS OS TESTES PASSARAM!"
            severity note;

        report "================================"
            severity note;

        wait;

    end process;

end architecture;
