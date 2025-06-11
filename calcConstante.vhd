library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calcConstante is
    port(
        constante   : in unsigned(7 downto 0); -- constante a ser escrita
        saida_cnte  : out unsigned(15 downto 0) -- saída da constante
    );
end entity;

architecture a_calcConstante of calcConstante is
begin
    saida_cnte <= "00000000" & constante;
end architecture;
