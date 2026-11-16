library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_merge_sort is
    generic(
        NUM_ELEMENTOS : integer := 8;
        NUM_ALEATORIOS : integer := 300
    );
end entity;

architecture test of tb_merge_sort is

    type vec_t is array (0 to NUM_ELEMENTOS-1) of integer range 0 to 255;

    signal clk     : std_logic := '0';
    signal reset   : std_logic := '0';
    signal start   : std_logic := '0';
    signal done    : std_logic;
    signal load    : std_logic := '0';
    signal data_in : std_logic_vector(NUM_ELEMENTOS*8-1 downto 0) := (others => '0');
    signal rd_addr : integer range 0 to NUM_ELEMENTOS := 0;
    signal rd_data : std_logic_vector(7 downto 0);

    signal fim : boolean := false;

    -- elemento 0 nos 8 bits mais significativos (mesma ordem do register_bank)
    function pack(v : vec_t) return std_logic_vector is
        variable r : std_logic_vector(NUM_ELEMENTOS*8-1 downto 0);
    begin
        for i in 0 to NUM_ELEMENTOS-1 loop
            r((NUM_ELEMENTOS-i)*8-1 downto (NUM_ELEMENTOS-i-1)*8) :=
                std_logic_vector(to_unsigned(v(i), 8));
        end loop;
        return r;
    end function;

    -- modelo de referencia (insertion sort)
    function ordena(v : vec_t) return vec_t is
        variable a : vec_t := v;
        variable t : integer;
        variable j : integer;
    begin
        for i in 1 to NUM_ELEMENTOS-1 loop
            t := a(i);
            j := i - 1;
            while j >= 0 and a(j) > t loop
                a(j+1) := a(j);
                j := j - 1;
            end loop;
            a(j+1) := t;
        end loop;
        return a;
    end function;

begin

    uut: entity work.merge_sort
        generic map(NUM_ELEMENTOS => NUM_ELEMENTOS)
        port map(
            clk     => clk,
            reset   => reset,
            start   => start,
            done    => done,
            load    => load,
            data_in => data_in,
            rd_addr => rd_addr,
            rd_data => rd_data
        );

    clk <= not clk after 5 ns when not fim else clk;

    process
        variable seed   : integer := 12345;
        variable v      : vec_t;
        variable esp    : vec_t;
        variable ciclos : integer;
        variable n_erros : integer := 0;
        variable n_testes : integer := 0;
        variable max_ciclos : integer := 0;

        procedure executa(entrada : vec_t; nome : string) is
        begin
            esp := ordena(entrada);

            -- carga
            data_in <= pack(entrada);
            load <= '1';
            wait until rising_edge(clk);
            wait for 1 ns;
            load <= '0';

            -- start de um ciclo
            start <= '1';
            wait until rising_edge(clk);
            wait for 1 ns;
            start <= '0';

            assert done = '0'
                report "done deveria cair apos start (" & nome & ")"
                severity error;

            -- espera done (com timeout)
            ciclos := 0;
            while done /= '1' and ciclos < 2000 loop
                wait until rising_edge(clk);
                wait for 1 ns;
                ciclos := ciclos + 1;
            end loop;

            assert done = '1'
                report "TIMEOUT esperando done (" & nome & ")"
                severity failure;

            if ciclos > max_ciclos then
                max_ciclos := ciclos;
            end if;

            -- confere resultado
            for i in 0 to NUM_ELEMENTOS-1 loop
                rd_addr <= i;
                wait for 1 ns;
                if to_integer(unsigned(rd_data)) /= esp(i) then
                    n_erros := n_erros + 1;
                    report "ERRO em " & nome & ": posicao " & integer'image(i) &
                           " obtido=" & integer'image(to_integer(unsigned(rd_data))) &
                           " esperado=" & integer'image(esp(i))
                        severity error;
                end if;
            end loop;

            -- done deve permanecer em 1 sem novo start
            wait until rising_edge(clk);
            wait for 1 ns;
            assert done = '1'
                report "done nao permaneceu em 1 (" & nome & ")"
                severity error;

            n_testes := n_testes + 1;
        end procedure;

        impure function rnd return integer is
        begin
            seed := (seed * 75) mod 65537;
            return (seed / 3) mod 256;
        end function;

    begin
        report "INICIANDO TESTES DO MERGE SORT (N = " &
               integer'image(NUM_ELEMENTOS) & ")" severity note;

        reset <= '1';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';
        wait until rising_edge(clk);
        wait for 1 ns;

        assert done = '0' report "done deveria ser 0 apos reset" severity error;

        -- exemplo do enunciado: 7 3 9 2 5 (completado com 1, 8, 4...)
        for i in 0 to NUM_ELEMENTOS-1 loop
            case i mod 8 is
                when 0 => v(i) := 7;
                when 1 => v(i) := 3;
                when 2 => v(i) := 9;
                when 3 => v(i) := 2;
                when 4 => v(i) := 5;
                when 5 => v(i) := 1;
                when 6 => v(i) := 8;
                when others => v(i) := 4;
            end case;
        end loop;
        executa(v, "exemplo");

        -- ja ordenado
        for i in 0 to NUM_ELEMENTOS-1 loop v(i) := i * 3; end loop;
        executa(v, "ordenado");

        -- ordem inversa
        for i in 0 to NUM_ELEMENTOS-1 loop v(i) := 255 - i * 3; end loop;
        executa(v, "inverso");

        -- todos iguais
        for i in 0 to NUM_ELEMENTOS-1 loop v(i) := 42; end loop;
        executa(v, "iguais");

        -- repetidos
        for i in 0 to NUM_ELEMENTOS-1 loop v(i) := (i mod 3) * 10; end loop;
        executa(v, "repetidos");

        -- extremos 0 e 255
        for i in 0 to NUM_ELEMENTOS-1 loop
            if i mod 2 = 0 then v(i) := 255; else v(i) := 0; end if;
        end loop;
        executa(v, "extremos");

        -- aleatorios
        for t in 1 to NUM_ALEATORIOS loop
            for i in 0 to NUM_ELEMENTOS-1 loop v(i) := rnd; end loop;
            executa(v, "aleatorio " & integer'image(t));
        end loop;

        -- reset no meio da operacao e nova ordenacao
        data_in <= pack(v);
        load <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        load <= '0';
        start <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        start <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        reset <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        reset <= '0';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert done = '0' report "done deveria ser 0 apos reset no meio" severity error;
        for i in 0 to NUM_ELEMENTOS-1 loop v(i) := rnd; end loop;
        executa(v, "apos reset");

        report "Testes executados: " & integer'image(n_testes) &
               " | latencia maxima (ciclos ate done): " & integer'image(max_ciclos)
            severity note;

        if n_erros = 0 then
            report "TODOS OS TESTES PASSARAM!" severity note;
        else
            report "FALHARAM " & integer'image(n_erros) & " COMPARACOES" severity failure;
        end if;

        fim <= true;
        wait;
    end process;

end architecture;
