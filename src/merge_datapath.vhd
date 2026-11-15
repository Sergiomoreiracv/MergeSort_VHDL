library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity merge_datapath is
    generic(
        NUM_ELEMENTOS : integer := 8
    );
    port(
        clk : in std_logic;
        reset : in std_logic;

        load_a : in std_logic;
        load_b : in std_logic;
        load_data : in std_logic_vector(NUM_ELEMENTOS*8-1 downto 0);

        read_bank : in std_logic;
        read_addr_a : in integer range 0 to NUM_ELEMENTOS;
        read_addr_b : in integer range 0 to NUM_ELEMENTOS;

        write_a : in std_logic;
        write_b : in std_logic;
        write_en : in std_logic;
        write_addr : in integer range 0 to NUM_ELEMENTOS;
        select_data : in std_logic;

        data_a : out std_logic_vector(7 downto 0);
        data_b : out std_logic_vector(7 downto 0);
        a_menor : out std_logic
    );
end entity;

architecture Behavioral of merge_datapath is

    signal data_a_bank_a : std_logic_vector(7 downto 0);
    signal data_b_bank_a : std_logic_vector(7 downto 0);

    signal data_a_bank_b : std_logic_vector(7 downto 0);
    signal data_b_bank_b : std_logic_vector(7 downto 0);

    signal write_data : std_logic_vector(7 downto 0);

    signal read_data_a : std_logic_vector(7 downto 0);
    signal read_data_b : std_logic_vector(7 downto 0);

begin

    banco_a: entity work.register_bank
        generic map(
            NUM_ELEMENTOS => NUM_ELEMENTOS
        )
        port map(
            clk => clk,
            reset => reset,
            load_en => load_a,
            load_data => load_data,
            write_en => write_en and write_a,
            write_addr => write_addr,
            write_data => write_data,
            read_add_a => read_addr_a,
            read_add_b => read_addr_b,
            read_data_a => data_a_bank_a,
            read_data_b => data_b_bank_a
        );

    banco_b: entity work.register_bank
        generic map(
            NUM_ELEMENTOS => NUM_ELEMENTOS
        )
        port map(
            clk => clk,
            reset => reset,
            load_en => load_b,
            load_data => load_data,
            write_en => write_en and write_b,
            write_addr => write_addr,
            write_data => write_data,
            read_add_a => read_addr_a,
            read_add_b => read_addr_b,
            read_data_a => data_a_bank_b,
            read_data_b => data_b_bank_b
        );

    -- Escolher o banco que será lido
    process(read_bank, data_a_bank_a, data_b_bank_a,
            data_a_bank_b, data_b_bank_b)
    begin
        if read_bank = '0' then
            read_data_a <= data_a_bank_a;
            read_data_b <= data_b_bank_a;
        else
            read_data_a <= data_a_bank_b;
            read_data_b <= data_b_bank_b;
        end if;
    end process;

    -- Comparador
    comparador: entity work.merge_comparator
        port map(
            data_a => read_data_a,
            data_b => read_data_b,
            a_menor => a_menor
        );

    data_a <= read_data_a;
    data_b <= read_data_b;

    process(select_data, read_data_a, read_data_b)
    begin
        if select_data = '0' then
            write_data <= read_data_a;
        else
            write_data <= read_data_b;
        end if;
    end process;

end architecture;