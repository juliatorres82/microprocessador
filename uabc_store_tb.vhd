library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity uabc_store_tb is
end entity;

architecture sim of uabc_store_tb is
    component uabc
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            constanteIn : in unsigned(7 downto 0);
            reg_r       : in unsigned(3 downto 0);
            wr_en_reg   : in std_logic;
            eh_I        : in std_logic;
            eh_LI       : in std_logic;
            eh_mv       : in std_logic;
            opcode      : in unsigned(3 downto 0);
            borrow_in   : in std_logic;
            wr_en_ac    : in std_logic;
            en_dataOutBK: in std_logic;
            zero        : out std_logic;
            dadoCalc    : out unsigned(15 downto 0)
        );
    end component;

    -- Sinais de teste
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '1';
    signal constanteIn  : unsigned(7 downto 0) := (others => '0');
    signal reg_r        : unsigned(3 downto 0) := (others => '0');
    signal wr_en_reg    : std_logic := '0';
    signal eh_I         : std_logic := '0';
    signal eh_LI        : std_logic := '0';
    signal eh_mv        : std_logic := '0';
    signal opcode       : unsigned(3 downto 0) := (others => '0');
    signal borrow_in    : std_logic := '0';
    signal wr_en_ac     : std_logic := '0';
    signal en_dataOutBK : std_logic := '0';
    signal zero         : std_logic;
    signal dadoCalc     : unsigned(15 downto 0);

    -- Constantes para os opcodes
    constant OP_LI    : unsigned(3 downto 0) := "1110";
    constant OP_ADDI  : unsigned(3 downto 0) := "1111";
    constant OP_MV    : unsigned(3 downto 0) := "0100";
    constant OP_STORE : unsigned(3 downto 0) := "1000";

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instância da UABC
    uut: uabc
        port map (
            clk         => clk,
            rst         => rst,
            constanteIn => constanteIn,
            reg_r      => reg_r,
            wr_en_reg   => wr_en_reg,
            eh_I        => eh_I,
            eh_LI       => eh_LI,
            eh_mv       => eh_mv,
            opcode      => opcode,
            borrow_in   => borrow_in,
            wr_en_ac    => wr_en_ac,
            en_dataOutBK=> en_dataOutBK,
            zero        => zero,
            dadoCalc    => dadoCalc
        );

    -- Geração de clock
    clk <= not clk after CLK_PERIOD/2;

    -- Processo de teste
    stimulus: process
        variable error_count : integer := 0;
        variable line_var : line;
    begin
        -- Inicialização
        write(line_var, string'("Iniciando teste do STORE..."));
        writeline(output, line_var);
        wait for CLK_PERIOD * 2;
        rst <= '0';
        wait for CLK_PERIOD;

        --------------------------------------------
      
        -- 1. Carrega valor 1 no reg 1
        -- 2. move reg 1 para ac
        -- 3. store valor no r2
        -- 4. store valor no r3

        -- teste 1 LI R1, 1
        eh_I <= '1';
        eh_LI <= '1';
        constanteIn <= x"01";
        wr_en_ac <= '1'; -- verificar se passa pelo ac;
        reg_r <= "0001";
        wr_en_reg <= '1';
        opcode <= "1110";
        wait for CLK_PERIOD;
        eh_I <= '0';
        eh_LI <= '0';
        wr_en_ac <= '0'; 
        wr_en_reg <= '0';


        -- 2: MV AC, R1
        eh_mv <= '1';
        wr_en_ac <= '1';
        wr_en_reg <= '0';
        reg_r <= "0001";
        en_dataOutBK <= '1';
        opcode <= "0100";
        wait for CLK_PERIOD;
        eh_mv <= '0';
        wr_en_ac <= '0';

        -- 3. STORE AC, R2
        reg_r <= "0010";
        en_dataOutBK <= '0';
        wr_en_reg <= '1';
        opcode <= "1000";
        wait for CLK_PERIOD;
        wr_en_reg <= '0';
        en_dataOutBK <= '1';

        -- 4. STORE AC, R3:
        reg_r <= "0011";
        en_dataOutBK <= '0';
        wr_en_reg <= '1';
        opcode <= "1000";
        wait for CLK_PERIOD;
        wr_en_reg <= '0';
        en_dataOutBK <= '1';

    
        
        -- 1. Primeiro carrega R1 com valor conhecido
        eh_LI <= '1';
        wr_en_reg <= '1';
        en_dataOutBK <= '0';  -- Para escrita no banco
        reg_r <= "0001";  -- R1
        constanteIn <= x"DE";
        wait for CLK_PERIOD;
        eh_LI <= '0';
        wr_en_reg <= '0';
        
        -- 2. Move R1 para acumulador
        eh_mv <= '1';
        wr_en_ac <= '1';
        en_dataOutBK <= '1';  -- Para leitura do banco
        reg_r <= "0001";
        opcode <= OP_MV;
        wait for CLK_PERIOD;
        eh_mv <= '0';
        wr_en_ac <= '0';
        en_dataOutBK <= '0';
        
        -- 3. STORE acumulador em R6 (com en_dataOutBK = '0')
        wr_en_reg <= '1';
        en_dataOutBK <= '0';
        reg_r <= "0110";  -- R6
        opcode <= OP_STORE;
        wait for CLK_PERIOD;
        wr_en_reg <= '0';
        opcode <= (others => '0');
        
        
        wait;
    end process;

end architecture;