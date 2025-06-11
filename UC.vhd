library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UC is 
    port (
        clk         : in std_logic;                 -- OK
        rst         : in std_logic;                 -- OK
        instrucao   : in unsigned (15 downto 0);    -- OK
        jump_adrss  : out unsigned(6 downto 0);     -- OK
        jump_en     : out std_logic;                -- OK
        wrEn_addPC  : out std_logic;                -- OK
        wrEn_PC     : out std_logic;                -- OK
        wrEn_RI     : out std_logic;                -- OK
        eh_I        : out std_logic;                -- OK
        eh_R        : out std_logic;
        constante   : out unsigned(7 downto 0);     -- OK
        qual_reg    : out unsigned(3 downto 0);     -- OK
        eh_mv       : out std_logic;
        wrEn_reg    : out std_logic;
        en_dataOutBK: out std_logic; -- zera só no comando store
        opcode      : out unsigned(3 downto 0);     -- OK
        eh_LI       : out std_logic;                -- OK
        reset_acu   : out std_logic;                -- OK
        wrEn_acu    : out std_logic
    );
end entity;

architecture a_UC of UC is 
    component maq_estados is
        port(
            clk, rst: in std_logic;
            estado: out unsigned(1 downto 0)
        );
    end component;

    signal estado_atual : unsigned(1 downto 0) := "00";
    signal opc          : unsigned(3 downto 0); 
    signal reg_esc      : unsigned(3 downto 0);
    signal cnte         : unsigned(7 downto 0);
    signal endereco     : unsigned(6 downto 0);
    signal ehMV         : std_logic;
    signal ehR          : std_logic;
    signal ehI          : std_logic;
    signal ehLI         : std_logic;
    
    -- fetch (estado 00): wrEN pc, addpc, reg_inst = 1.
    -- decode/execute: (estado 01): wrEn pc, addpc, reg_inst = 0. wrEnReg = 1 if not mv; wrEnAcu = '1'
    
    begin
    maq : maq_estados port map (
        clk => clk,
        rst => rst,
        estado => estado_atual
    );

    opc <= instrucao(15 downto 12);
    reg_esc <= instrucao(11 downto 8);
    cnte <= instrucao(7 downto 0);
    endereco <= instrucao(11 downto 5);
    
    -- tipos de instrução: I (addi, subi, li), R (add), mv e store.
    eh_I <= '1' when (opc = "1111" or opc = "1110" or opc ="0001") else '0';
    eh_R <= '1' when opc = "1100" else '0';
    eh_LI <= '1' when opc = "1110" else '0';
    eh_mv <= '1' when opc = "0100" else '0';

    --sinais internos 
    ehMV <= '1' when opc = "0100" else '0';
    ehI <= '1' when (opc = "1111" or opc = "1110" or opc ="0001") else '0';
    ehLI <= '1' when opc = "1110" else '0';
    ehR <= '1' when opc = "1100" else '0';
    jump_en <= '1' when opc = "0101" else '0';

    -- quando instrução é store:
    en_dataOutBK <= '0' when opc = "1000" else '1';

    -- para resetar acumulador:
    reset_acu <= '1' when rst = '1';

    -- fetch:
    wrEn_addPC <= '1' when estado_atual = "01" else '0';
    wrEn_PC    <= '1' when estado_atual = "01" else '0';
    wrEn_RI    <= '1' when estado_atual = "00" else '0';
    wrEn_reg   <= '1' when estado_atual = "01" and (ehLI = '1' or opc = "1000") and opc /= "0101" else '0'; --ativo qndo li ou store
    wrEn_acu   <= '1' when estado_atual = "01" and (ehI ='1' or ehMV = '1' or ehR = '1') else '0';


    -- sinais finais
    opcode <= opc;
    qual_reg <= reg_esc;
    constante <= cnte;
    jump_adrss <= endereco;

end architecture;