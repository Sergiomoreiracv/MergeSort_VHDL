
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register_bank is
    generic(
        NUM_ELEMENTOS : integer := 8
    );

    port (
        clk : in std_logic;
        reset : in std_logic;

        load_en : in std_logic;
        load_data : in std_logic_vector(NUM_ELEMENTOS*8-1 downto 0);

        write_en : in std_logic;
        write_addr : in integer range 0 to NUM_ELEMENTOS;
        write_data : in std_logic_vector(7 downto 0);

        read_add_a : in integer range 0 to NUM_ELEMENTOS;
        read_add_b : in integer range 0 to NUM_ELEMENTOS;

        read_data_a : out std_logic_vector(7 downto 0);
        read_data_b : out std_logic_vector(7 downto 0);

        -- para entregar todos
        data_all : out std_logic_vector(NUM_ELEMENTOS*8 - 1 downto 0)
    );
end entity;

architecture Behavioral of register_bank is

    type banco_t is array (0 to NUM_ELEMENTOS-1)
        of std_logic_vector(7 downto 0);

    signal registradores : banco_t;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                registradores <= (others => (others => '0'));

            elsif load_en = '1' then
                for i in 0 to NUM_ELEMENTOS-1 loop
                    registradores(i) <= load_data(
                        (NUM_ELEMENTOS-i)*8-1 downto
                        (NUM_ELEMENTOS-i-1)*8
                    );
                end loop;

            elsif write_en = '1' and write_addr < NUM_ELEMENTOS then
                registradores(write_addr) <= write_data;

            end if;
        end if;
    end process;

    read_data_a <= registradores(read_add_a)
        when read_add_a < NUM_ELEMENTOS else (others => '0');

    read_data_b <= registradores(read_add_b)
        when read_add_b < NUM_ELEMENTOS else (others => '0');

            gen_all : for idx in 0 to NUM_ELEMENTOS-1 generate
        data_all((NUM_ELEMENTOS-idx)*8-1 downto
                 (NUM_ELEMENTOS-idx-1)*8) <= registradores(idx);
    end generate;

end architecture;
