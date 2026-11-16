
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity merge_comparator is
    port (
        data_a : in std_logic_vector(7 downto 0);
        data_b : in std_logic_vector(7 downto 0);
        a_menor : out std_logic
    );
end entity;

architecture Behavioral of merge_comparator is
begin

    process(data_a, data_b)
    begin
        if unsigned(data_a) <= unsigned(data_b) then
            a_menor <= '1';
        else
            a_menor <= '0';
        end if;
    end process;

end architecture;
