-- =====================================================================
-- pega_esq.vhd
--
-- Logica que decide, a cada clock do MERGE, DE QUAL LADO vem o proximo
-- elemento a ser gravado no banco destino:
--
--     sel_esq = '1'  ->  pega x (lado ESQUERDO), avanca i
--     sel_esq = '0'  ->  pega y (lado DIREITO),  avanca j
--
-- A regra, em linguagem de algoritmo:
--
--     pega a esquerda se:  o lado direito ja acabou   (j >= hi)
--                      OU  (a esquerda ainda tem elementos (i < mid)
--                           E x <= y)
--
-- Por que a regra precisa ser exatamente essa:
--
--   caso 1: direita acabou (j >= hi)
--       Sobra so a esquerda. Nao adianta comparar: y e lixo (o mux
--       esta lendo uma posicao de OUTRO par). Pega x sem olhar y.
--
--   caso 2: esquerda acabou (i >= mid), direita ainda tem
--       i < mid e falso, entao a parte "(i < mid) e (x <= y)" e falsa.
--       Como j >= hi tambem e falso, sel_esq = '0': pega y. Correto,
--       e x (lixo) nunca influencia a decisao.
--
--   caso 3: os dois lados tem elementos
--       i < mid verdadeiro, j >= hi falso, entao so conta x <= y:
--       pega o menor; em empate (x = y) pega a esquerda.
--
--   caso 4: os dois acabaram
--       Nao ocorre dentro do MERGE: o par termina na hora em que o
--       ultimo elemento e gravado (flag k_last).
--
-- E COMBINACIONAL (sem clock). Fica no meio do caminho:
--     comparator ----- x_le_y ---\
--     flags --------- i_lt_mid ----> pega_esq ---> mux de escrita
--     flags --------- j_ge_hi  ---/               e enables de i / j
--
-- Obs.: a saida se chama sel_esq (e nao pega_esq) para nao repetir o
-- nome da entidade. No top, ligue-a ao sinal "pega_esq".
-- =====================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pega_esq is
    port (
        -- x menor ou igual a y
        x_le_y   : in  std_logic;   
    
        -- i menor que mid [esquerda tem elementos]
        i_lt_mid : in  std_logic;   

        -- j maior ou igual a hi [direita acabou]
        j_ge_hi  : in  std_logic;   

        -- se 1 -> pega esquerda || se 0 -> pega direita 
        sel_esq  : out std_logic    
    );
end entity;

architecture Behavioral of pega_esq is
begin

    -- Em VHDL, "or" e "and" entre std_logic sao portas logicas de verdade.
    -- Parenteses explicitos: o "and" ja teria prioridade sobre o "or" em
    -- muitas linguagens, mas em VHDL misturar "and" e "or" sem parenteses
    -- e ERRO de compilacao. Os parenteses deixam a intencao clara.
    sel_esq <= j_ge_hi or (i_lt_mid and x_le_y);

end architecture;