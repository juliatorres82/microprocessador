library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addPC is
    port(
        entrada     :in unsigned(6 downto 0);
        wr_en       :in std_logic;
        saida       :out unsigned(6 downto 0)
    );
end entity;

architecture a_addPC of addPC is
    signal temp_out : unsigned(6 downto 0) := (others => '0');
begin
    temp_out <=
                entrada + 1 when wr_en = '1' else
                entrada;

    saida <= temp_out;
end architecture;
