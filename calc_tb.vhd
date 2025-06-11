library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calc_tb is
end entity;

architecture a_calc of calc_tb is

    component calculadora is 
        port(
            clk     : in std_logic;
            rst     : in std_logic;
            zero    : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal zero : std_logic;
    
    constant clock_period : time := 20 ns;

begin
    dut: calculadora port map(
        clk => clk,
        rst => rst,
        zero => zero
    );

    clock_process: process
    begin
        clk <= '0';
        wait for clock_period/2;
        clk <= '1';
        wait for clock_period/2;
    end process;

    stim_proc: process
    begin
        rst <= '1';
        wait for clock_period;
        rst <= '0';
        
        wait for 200 ns;
        wait;
    end process;

end architecture;