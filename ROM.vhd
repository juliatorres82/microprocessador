library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM is
    port(
        clk      : in std_logic;
        endereco : in unsigned(6 downto 0); --128 enderecos
        dado     : out unsigned(15 downto 0) -- largura de 16 bits
    );
end entity;

architecture a_rom of ROM is
    type mem is array (0 to 127) of unsigned (15 downto 0);
    constant conteudo_rom : mem := (
        0 => "1110001100000101", -- li r3, 5 
        1 => "1110010000001000", -- li r4, 8
        2 => "0100001100000000", -- mv r3
        3 => "1100010000000000", -- addi ac, r4
        4 => "1000010100000000", -- store r5
        5 => "0100010100000000", -- mv r5, 
        6 => "0001000000000001", -- subi Ac, 1
        7 => "1000010100000000", -- store r5
        8 => "0101001010000000", -- jump &=20
        9 => "1110010100000000", -- li r5, 0 (nunca será executado)

        20 => "0100001100000000", -- mv r3
        21 => "1000010100000000", -- store r5
        22 => "0101000001100000", -- jump &=3
        23 => "1110001100000000", -- li r3, 0 (nunca será executado)
        others => (others => '0')
    );
begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            -- saída "dado" envia o conteúdo do endereço
            dado <= conteudo_rom(to_integer(endereco));
        end if;
    end process;
end architecture;