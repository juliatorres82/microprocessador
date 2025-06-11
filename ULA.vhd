library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is 
    port(
        acumulador_in  : in unsigned(15 downto 0);  -- valor do AC
        B              : in unsigned(15 downto 0);  -- valor do registrador B
        opcode         : in unsigned(3 downto 0);
        borrow_in      : in std_logic;              -- para SUBB
        outULA         : out unsigned(15 downto 0);
        zero           : out std_logic
    );
end entity;

architecture a_ULA of ULA is

    signal temp_result : unsigned(15 downto 0);
    signal clz_count   : integer range 0 to 16;

begin
                   -- Instruções I:
    temp_result <=
                    acumulador_in + B when opcode = "1111" else                         -- ADDI (addi ac,4)
                    acumulador_in + B when opcode = "1100" else                         -- ADD (add ac, r1)
                    acumulador_in - B when opcode = "0001" and borrow_in = '0' else     -- SUBI (SUBTRAÇÃO)
                    acumulador_in - B - 1 when opcode = "0001" and borrow_in = '1' else -- SUBB (SUBTRAÇÃO COM BORROW)

                    --Outras instruções:
                    acumulador_in  when opcode = "0100" else                            -- MOVE (move um valor para o acumulador)
                    acumulador_in when opcode = "1000" else                             -- STORE
                    (others => '0'); -- 0000 reseta, por ex

    zero <= 
                    '1' when acumulador_in - B = "0000000000000000" else 
                    '0';

    outULA <= temp_result;
end architecture;
