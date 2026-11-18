-- =====================================================================
-- write_decoder.vhd
--
-- Decide QUAL BANCO recebe a escrita neste clock.
--
-- A decodificacao da escrita acontece em DOIS niveis:
--
--   nivel 1 (este arquivo):  qual BANCO grava?   A ou B ou nenhum
--   nivel 2 (register_bank): qual REGISTRADOR do banco grava?
--                            (o proprio banco faz isso quando recebe
--                             write_addr = k e executa
--                             registradores(write_addr) <= write_data)
--
-- Entradas:
--   write_en : '1' so no estado MERGE (a FSM liga). Fora dele, nada grava.
--   src      : qual banco e a ORIGEM. O destino e sempre o oposto:
--                src = 0  (A e origem)  ->  destino = B  ->  we_b = '1'
--                src = 1  (B e origem)  ->  destino = A  ->  we_a = '1'
--
-- Saidas:
--   we_a / we_b : ligam no write_en de cada register_bank.
--
-- Tabela verdade:
--
--     write_en | src | we_a | we_b
--     ---------+-----+------+------
--        0     |  x  |  0   |  0     (nao e hora de gravar)
--        1     |  0  |  0   |  1     (le de A, grava em B)
--        1     |  1  |  1   |  0     (le de B, grava em A)
--
-- Garantia importante: we_a e we_b NUNCA ficam ligados juntos. Isso e o
-- que impede um banco de ser lido e escrito ao mesmo tempo.
--
-- E COMBINACIONAL (sem clock).
--
-- Observacao: o k nao entra aqui porque o register_bank ja recebe k
-- como write_addr e decodifica por dentro. Se voce preferir um banco
-- que receba um vetor "we" de 8 bits (um enable por registrador), este
-- arquivo passa a receber k tambem e gera we_a(7 downto 0) e
-- we_b(7 downto 0) - nesse caso o register_bank precisa ser ajustado.
-- =====================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--vai decidir qual banco grava, o A ou B
--qual registrador do banco grava ta sendo decidido no register_bank


--o k nao entra aqui porque o register_bank ja recebe k
--como write_addr e decodifica



entity write_decoder is
    port (
        -- 1-> grava
        write_en : in  std_logic;               -- '1' = e hora de gravar (MERGE)

        -- se 0 -> A origem || se 1 -> B origem
        src      : in  integer range 0 to 1;    -- 0 = A e origem, 1 = B e origem

        -- habilita escrever em A
        we_a     : out std_logic;               -- habilita escrita no banco A

        -- habilita escrever em B
        we_b     : out std_logic                -- habilita escrita no banco B
    );
end entity;

architecture Behavioral of write_decoder is
begin

    
    we_b <= '1' when write_en = '1' and src = 0 else '0';
    we_a <= '1' when write_en = '1' and src = 1 else '0';

end architecture;