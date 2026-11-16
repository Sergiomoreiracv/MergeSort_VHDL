library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Unidade de controle do Merge Sort bottom-up (iterativo).
--
-- Estados:
--   IDLE     : espera start
--   INIT     : width <= 1, i <= 0, origem = banco A
--   SETUP    : posiciona ponteiros do par de runs atual
--   MERGE    : escolhe o menor (ou drena a run restante) e escreve em dst[k]
--   NEXT_RUN : avanca i para o proximo par de runs
--   PASS     : dobra width e troca os bancos (ping-pong)
--   DONE_ST  : done = '1' ate um novo start
--
-- Convencao: src_sel = '0' -> origem e o banco A (destino B)
--            src_sel = '1' -> origem e o banco B (destino A)
-- Ao terminar, o resultado esta no banco indicado por src_sel
-- (read_bank = src_sel), que e lido por rd_addr enquanto nao esta ocupado.

entity merge_control is
    generic(
        NUM_ELEMENTOS : integer := 8
    );
    port(
        clk   : in std_logic;
        reset : in std_logic;
        start : in std_logic;
        done  : out std_logic;
        busy  : out std_logic;

        -- leitura externa do resultado (fora do MERGE)
        rd_addr : in integer range 0 to NUM_ELEMENTOS;

        -- sinais para o datapath
        read_bank   : out std_logic;
        read_addr_a : out integer range 0 to NUM_ELEMENTOS;
        read_addr_b : out integer range 0 to NUM_ELEMENTOS;
        write_a     : out std_logic;
        write_b     : out std_logic;
        write_en    : out std_logic;
        write_addr  : out integer range 0 to NUM_ELEMENTOS;
        select_data : out std_logic;

        -- retorno do datapath
        a_menor : in std_logic
    );
end entity;

architecture Behavioral of merge_control is

    type state_t is (IDLE, INIT, SETUP, MERGE, NEXT_RUN, PASS, DONE_ST);
    signal state, next_state : state_t := IDLE;

    subtype ptr_t is integer range 0 to NUM_ELEMENTOS;
    subtype big_t is integer range 0 to 3*NUM_ELEMENTOS;

    signal width,  width_n  : big_t := 1;
    signal i_r,    i_n      : big_t := 0;
    signal l_idx,  l_idx_n  : ptr_t := 0;
    signal r_idx,  r_idx_n  : ptr_t := 0;
    signal l_end,  l_end_n  : ptr_t := 0;
    signal r_end,  r_end_n  : ptr_t := 0;
    signal k,      k_n      : ptr_t := 0;
    signal src_sel, src_sel_n : std_logic := '0';

    signal start_prev : std_logic := '0';
    signal start_rise : std_logic;

    function imin(a, b : integer) return integer is
    begin
        if a < b then
            return a;
        else
            return b;
        end if;
    end function;

begin

    start_rise <= start and not start_prev;

    ------------------------------------------------------------------
    -- Registradores
    ------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state      <= IDLE;
                width      <= 1;
                i_r        <= 0;
                l_idx      <= 0;
                r_idx      <= 0;
                l_end      <= 0;
                r_end      <= 0;
                k          <= 0;
                src_sel    <= '0';
                start_prev <= '0';
            else
                state      <= next_state;
                width      <= width_n;
                i_r        <= i_n;
                l_idx      <= l_idx_n;
                r_idx      <= r_idx_n;
                l_end      <= l_end_n;
                r_end      <= r_end_n;
                k          <= k_n;
                src_sel    <= src_sel_n;
                start_prev <= start;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------
    -- Proximo estado e saidas (combinacional)
    ------------------------------------------------------------------
    process(state, width, i_r, l_idx, r_idx, l_end, r_end, k, src_sel,
            start_rise, a_menor, rd_addr)
    begin
        -- valores padrao: mantem tudo (evita latches)
        next_state <= state;
        width_n    <= width;
        i_n        <= i_r;
        l_idx_n    <= l_idx;
        r_idx_n    <= r_idx;
        l_end_n    <= l_end;
        r_end_n    <= r_end;
        k_n        <= k;
        src_sel_n  <= src_sel;

        done        <= '0';
        busy        <= '1';
        read_bank   <= src_sel;
        read_addr_a <= rd_addr;
        read_addr_b <= 0;
        write_a     <= src_sel;        -- origem B -> escreve em A
        write_b     <= not src_sel;    -- origem A -> escreve em B
        write_en    <= '0';
        write_addr  <= 0;
        select_data <= '0';

        case state is

            when IDLE =>
                busy <= '0';
                if start_rise = '1' then
                    next_state <= INIT;
                end if;

            when INIT =>
                width_n   <= 1;
                i_n       <= 0;
                src_sel_n <= '0';
                next_state <= SETUP;

            when SETUP =>
                l_idx_n <= imin(i_r, NUM_ELEMENTOS);
                r_idx_n <= imin(i_r + width, NUM_ELEMENTOS);
                l_end_n <= imin(i_r + width, NUM_ELEMENTOS);
                r_end_n <= imin(i_r + 2*width, NUM_ELEMENTOS);
                k_n     <= imin(i_r, NUM_ELEMENTOS);
                next_state <= MERGE;

            when MERGE =>
                read_addr_a <= l_idx;
                read_addr_b <= r_idx;
                write_en    <= '1';
                write_addr  <= k;

                -- escolhe a esquerda se ela ainda tem elementos e
                -- (a direita acabou ou a esquerda e menor)
                if (l_idx < l_end) and
                   ((r_idx = r_end) or (a_menor = '1')) then
                    select_data <= '0';
                    l_idx_n     <= l_idx + 1;
                else
                    select_data <= '1';
                    r_idx_n     <= r_idx + 1;
                end if;

                k_n <= k + 1;
                if k + 1 = r_end then
                    next_state <= NEXT_RUN;
                end if;

            when NEXT_RUN =>
                i_n <= i_r + 2*width;
                if i_r + 2*width >= NUM_ELEMENTOS then
                    next_state <= PASS;
                else
                    next_state <= SETUP;
                end if;

            when PASS =>
                width_n   <= 2*width;
                i_n       <= 0;
                src_sel_n <= not src_sel;
                if 2*width >= NUM_ELEMENTOS then
                    next_state <= DONE_ST;
                else
                    next_state <= SETUP;
                end if;

            when DONE_ST =>
                busy <= '0';
                done <= '1';
                if start_rise = '1' then
                    next_state <= INIT;
                end if;

        end case;
    end process;

end architecture;
