library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uabc_tb is
end entity;

architecture sim of uabc_tb is
    -- Componente UABC (Unit Under Test)
    component uabc
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            constanteIn : in unsigned(7 downto 0);
            reg_r       : in unsigned(3 downto 0);
            wr_en_reg   : in std_logic;
            eh_I        : in std_logic;
            eh_LI       : in std_logic;
            eh_R        : in std_logic;
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
    signal eh_R         : std_logic := '0';
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
    constant OP_SUBI  : unsigned(3 downto 0) := "0001";
    constant OP_MV    : unsigned(3 downto 0) := "0100";
    constant OP_STORE : unsigned(3 downto 0) := "1000";
    constant OP_JUMP  : unsigned(3 downto 0) := "0101";

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
            eh_R        => eh_R,
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
    begin
        -- Reset inicial
        rst <= '1';
        wait for CLK_PERIOD * 2;
        rst <= '0';
        wait for CLK_PERIOD;

        -- Teste 1: LI (Load Immediate) - Carrega constante no registrador 1
        report "Teste 1: LI R1, 0x05";
        eh_LI <= '1';
        eh_I <= '1';
        wr_en_reg <= '1';
        reg_r <= "0001";  -- R1
        constanteIn <= "00000101";  -- 0x05
        wait for CLK_PERIOD;
        eh_LI <= '0';
        eh_I <= '0';
        wr_en_reg <= '0';
        wait for CLK_PERIOD;

        -- Teste 2: MV (Move) - Move R1 para o acumulador
        report "Teste 2: MV AC, R1";
        eh_mv <= '1';
        wr_en_ac <= '1';
        en_dataOutBK <= '1';
        reg_r <= "0001";  -- R1
        opcode <= OP_MV;
        wait for CLK_PERIOD;
        eh_mv <= '0';
        wr_en_ac <= '0';
        en_dataOutBK <= '0';
        wait for CLK_PERIOD;

        -- Teste 3: LI (Load Immediate) - Carrega constante no registrador 2
        report "Teste 1: LI R2, 0x02";
        eh_LI <= '1';
        wr_en_reg <= '1';
        reg_r <= "0010";  -- R2
        constanteIn <= "00000010";  -- 0x02
        wait for CLK_PERIOD;
        eh_LI <= '0';
        wr_en_reg <= '0';
        wait for CLK_PERIOD;

        -- Teste 4: ADD Ac, R2
        eh_R <= '1';
        wr_en_reg <= '0';
        reg_r <= "0010";
        opcode <= "1100";
        en_dataOutBK <= '1';
        wr_en_ac <= '1';
         wait for CLK_PERIOD;
        eh_R <= '0';
        wr_en_reg <= '0';
        wr_en_ac <= '0';
        en_dataOutBK <= '0';
        wait for CLK_PERIOD;

        -- Teste 3: ADDI (Add Immediate) - Soma 0x10 ao acumulador
        report "Teste 3: ADDI AC, 0x10";
        eh_I <= '1';
        wr_en_ac <= '1';
        constanteIn <= "00010000";  -- 0x10
        opcode <= OP_ADDI;
        wait for CLK_PERIOD;
        eh_I <= '0';
        wr_en_ac <= '0';
        wait for CLK_PERIOD;

        -- Verifica a soma
        assert dadoCalc = x"0065" 
            report "Erro no Teste 3: Soma incorreta" 
            severity error;

        -- Teste 4: SUBI (Subtract Immediate) - Subtrai 0x05 do acumulador
        report "Teste 4: SUBI AC, 0x05";
        eh_I <= '1';
        wr_en_ac <= '1';
        constanteIn <= "00000101";  -- 0x05
        opcode <= OP_SUBI;
        wait for CLK_PERIOD;
        eh_I <= '0';
        wr_en_ac <= '0';
        wait for CLK_PERIOD;

        -- Verifica a subtração
        assert dadoCalc = x"0060" 
            report "Erro no Teste 4: Subtração incorreta" 
            severity error;

        -- Teste 5: STORE - Armazena acumulador em R2
        report "Teste 5: STORE R2, AC";
        wr_en_reg <= '1';
        en_dataOutBK <= '0';
        reg_r <= "0010";  -- R2
        opcode <= OP_STORE;
        wait for CLK_PERIOD;
        wr_en_reg <= '0';
       -- en_dataOutBK <= '1';
        wait for CLK_PERIOD;

        -- Teste 6: MV - Move R2 para o acumulador para verificar o STORE
        report "Teste 6: MV AC, R2 (verificação do STORE)";
        eh_mv <= '1';
        wr_en_ac <= '1';
        en_dataOutBK <= '1';
        reg_r <= "0010";  -- R2
        opcode <= OP_MV;
        wait for CLK_PERIOD;
        eh_mv <= '0';
        wr_en_ac <= '0';
        en_dataOutBK <= '0';
        wait for CLK_PERIOD;

        -- Verifica se o valor foi armazenado corretamente
        assert dadoCalc = x"0060" 
            report "Erro no Teste 6: STORE não funcionou corretamente" 
            severity error;

        -- Teste 7: JUMP - Teste de condição de zero (simulado)
        report "Teste 7: JUMP (simulação de condição de zero)";
        opcode <= OP_JUMP;
        
        wait for CLK_PERIOD;
        opcode <= (others => '0');
        wait for CLK_PERIOD;


        -- Teste 8: Reset
        report "Teste 8: Reset";
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;

        -- Verifica se o reset limpou o acumulador
        assert dadoCalc = x"0000" 
            report "Erro no Teste 8: Reset não limpou o acumulador" 
            severity error;

        -- Finaliza a simulação
        report "Testes concluídos com sucesso!";
        wait;
    end process;

end architecture;