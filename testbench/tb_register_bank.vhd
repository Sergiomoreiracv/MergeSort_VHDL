
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_register_bank is
end entity;

architecture test of tb_register_bank is

    constant NUM_ELEMENTOS : integer := 8;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';

    signal load_en : std_logic := '0';
    signal load_data : std_logic_vector(63 downto 0) := (others => '0');

    signal write_en : std_logic := '0';
    signal write_addr : integer range 0 to 8 := 0;
    signal write_data : std_logic_vector(7 downto 0) := (others => '0');

    signal read_add_a : integer range 0 to 8 := 0;
    signal read_add_b : integer range 0 to 8 := 0;

    signal read_data_a : std_logic_vector(7 downto 0);
    signal read_data_b : std_logic_vector(7 downto 0);

begin

    clk <= not clk after 5 ns;

    uut: entity work.register_bank
        generic map (
            NUM_ELEMENTOS => NUM_ELEMENTOS
        )
        port map (
            clk => clk,
            reset => reset,
            load_en => load_en,
            load_data => load_data,
            write_en => write_en,
            write_addr => write_addr,
            write_data => write_data,
            read_add_a => read_add_a,
            read_add_b => read_add_b,
            read_data_a => read_data_a,
            read_data_b => read_data_b
        );

    process
    begin

        -- Teste 1: Reset
        reset <= '1';
        wait until rising_edge(clk);
        reset <= '0';

        -- Teste 2: Carregar os oito elementos
        load_data <= x"07" & x"03" & x"08" & x"01" &
                     x"05" & x"02" & x"06" & x"04";

        load_en <= '1';
        wait until rising_edge(clk);
        load_en <= '0';

        -- Teste 3: Ler duas posições
        read_add_a <= 0;
        read_add_b <= 1;

        wait for 1 ns;

        assert read_data_a = x"07"
            report "Erro na primeira leitura"
            severity error;

        assert read_data_b = x"03"
            report "Erro na segunda leitura"
            severity error;

        -- Teste 4: Escrever em uma posição
        write_en <= '1';
        write_addr <= 2;
        write_data <= x"09";

        wait until rising_edge(clk);
        write_en <= '0';

        -- Verificar a escrita
        read_add_a <= 2;
        wait for 1 ns;

        assert read_data_a = x"09"
            report "Erro na escrita"
            severity error;

        -- Teste 5: Reset novamente
        reset <= '1';
        wait until rising_edge(clk);
        reset <= '0';

        wait for 1 ns;

        assert read_data_a = x"00"
            report "Erro no reset"
            severity error;

        -- Teste 6: Endereço inválido
        read_add_a <= 8;
        wait for 1 ns;

        assert read_data_a = x"00"
            report "Erro no endereco invalido"
            severity error;

        report "Todos os testes foram concluidos!"
            severity note;

        wait;

    end process;

end architecture;
