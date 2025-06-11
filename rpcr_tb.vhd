library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rpcr_tb is
end entity;

architecture tb of rpcr_tb is

    signal clk           : std_logic := '0';
    signal rst           : std_logic := '1';
    signal wr_en_pc      : std_logic := '0';
    signal wr_en_addPC   : std_logic := '0';
    signal wr_en_regInst : std_logic := '0';
    signal jump_enable   : std_logic := '0';
    signal endPC_jump    : unsigned(6 downto 0) := (others => '0');
    signal instr_atual   : unsigned(15 downto 0);

    component ROM_pc_regInst is
        port(
            clk           : in std_logic;
            rst           : in std_logic;
            wr_en_pc      : in std_logic;
            wr_en_addPC   : in std_logic;
            wr_en_regInst : in std_logic;
            jump_enable   : in std_logic;
            endPC_jump    : in unsigned(6 downto 0);
            instr_atual   : out unsigned(15 downto 0)
        );
    end component;

    constant clock_period : time := 20 ns;

begin

   uut: ROM_pc_regInst
       port map (
           clk           => clk,
           rst           => rst,
           wr_en_pc      => wr_en_pc,
           wr_en_addPC   => wr_en_addPC,
           wr_en_regInst => wr_en_regInst,
           jump_enable   => jump_enable,
           endPC_jump    => endPC_jump,
           instr_atual   => instr_atual
       );

           clock_process: process
    begin
        clk <= '0';
        wait for clock_period/2;
        clk <= '1';
        wait for clock_period/2;
    end process;

    stimulus_process: process
    begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        -- ciclo 1:
        wr_en_pc <= '1';
        wr_en_addPC <= '1';
        wr_en_regInst <= '1';
        wait for 20 ns;

        wr_en_addPC <= '0';
        wr_en_regInst <= '0';
        wr_en_pc <= '0';

         -- ciclo 2:
        wr_en_pc <= '1';
        wr_en_addPC <= '1';
        wr_en_regInst <= '1';
        wait for 20 ns;

        wr_en_addPC <= '0';
        wr_en_regInst <= '0';
        wr_en_pc <= '0';

        -- ciclo 3:
         wr_en_pc <= '1';
        wr_en_addPC <= '1';
        wr_en_regInst <= '1';
        wait for 20 ns;

        wr_en_addPC <= '0';
        wr_en_regInst <= '0';
        wr_en_pc <= '0';

        -- ciclo 4:
        jump_enable <= '1';
        endPC_jump <= "0000001"; -- exemplo de endereço de salto
        wr_en_pc <= '1';
        wr_en_addPC <= '1';
        wr_en_regInst <= '1';
        wait for 20 ns;

        jump_enable <= '0';
        wr_en_addPC <= '0';
        wr_en_regInst <= '0';
        wr_en_pc <= '0';


        --ciclo 5:
        wr_en_pc <= '1';
        wr_en_addPC <= '1';
        wr_en_regInst <= '1';
        wait for 20 ns;

        wr_en_addPC <= '0';
        wr_en_regInst <= '0';
        wr_en_pc <= '0';

        -- ciclo 6:
        wr_en_pc <= '1';
        wr_en_addPC <= '1';
        wr_en_regInst <= '1';
        wait for 20 ns;

        wr_en_addPC <= '0';
        wr_en_regInst <= '0';
        wr_en_pc <= '0';

        wait;
    end process;
end architecture;


        