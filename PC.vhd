library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port (
        clk     : in std_logic;
        rst     : in std_logic;
        wr_en   : in std_logic;
        data_in : in unsigned(6 downto 0); --recebe do addPC o & da próxima instrução 
        data_out: out unsigned(6 downto 0) -- manda para A ROM o & da próxima instrução e para o addPC incrementar o PC
    );
end entity;

architecture a_pc of pc is
    signal registroPc: unsigned(6 downto 0);
begin
    process(clk, rst) 
    begin 
        if rst = '1' then  
            registroPc <= "0000000";
        elsif wr_en = '1' then
            if rising_edge(clk) then --if de inferir ff
                registroPc <= data_in;
            end if;
        end if;
    end process;

  data_out <= registroPc; 
  end architecture;
