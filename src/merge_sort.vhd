library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Top-level do Merge Sort em hardware.
--
-- Uso:
--   1. Com done = '0' e busy = '0' (ocioso), coloque load = '1' com a
--      sequencia em data_in por um ciclo de clock. O elemento 0 fica nos
--      8 bits mais significativos de data_in.
--   2. Pulse start por um ciclo (ou mantenha ate done).
--   3. Aguarde done = '1'.
--   4. Leia a sequencia ordenada com rd_addr = 0 .. N-1 (rd_data e
--      combinacional). done permanece em '1' ate um novo start.

entity merge_sort is
    generic(
        NUM_ELEMENTOS : integer := 8
    );
    port(
        clk   : in std_logic;
        reset : in std_logic;
        start : in std_logic;
        done  : out std_logic;

        -- entrada de dados
        load    : in std_logic;
        data_in : in std_logic_vector(NUM_ELEMENTOS*8-1 downto 0);

        -- saida de dados (leitura por endereco)
        rd_addr : in integer range 0 to NUM_ELEMENTOS;
        rd_data : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Structural of merge_sort is

    signal busy        : std_logic;
    signal load_a      : std_logic;

    signal read_bank   : std_logic;
    signal read_addr_a : integer range 0 to NUM_ELEMENTOS;
    signal read_addr_b : integer range 0 to NUM_ELEMENTOS;
    signal write_a     : std_logic;
    signal write_b     : std_logic;
    signal write_en    : std_logic;
    signal write_addr  : integer range 0 to NUM_ELEMENTOS;
    signal select_data : std_logic;
    signal a_menor     : std_logic;
    signal data_a      : std_logic_vector(7 downto 0);
    signal data_b      : std_logic_vector(7 downto 0);

begin

    -- a carga so e aceita com a maquina ociosa; sempre no banco A
    load_a <= load and not busy;

    controle: entity work.merge_control
        generic map(NUM_ELEMENTOS => NUM_ELEMENTOS)
        port map(
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

    caminho_dados: entity work.merge_datapath
        generic map(NUM_ELEMENTOS => NUM_ELEMENTOS)
        port map(
            clk         => clk,
            reset       => reset,
            load_a      => load_a,
            load_b      => '0',
            load_data   => data_in,
            read_bank   => read_bank,
            read_addr_a => read_addr_a,
            read_addr_b => read_addr_b,
            write_a     => write_a,
            write_b     => write_b,
            write_en    => write_en,
            write_addr  => write_addr,
            select_data => select_data,
            data_a      => data_a,
            data_b      => data_b,
            a_menor     => a_menor
        );

    rd_data <= data_a;

end architecture;
