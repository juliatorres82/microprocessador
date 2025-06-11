library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calculadora is
    port(
    clk     : in std_logic;
    rst     : in std_logic;
    zero    : out std_logic
    );
end entity;

architecture acalc of calculadora is

    component uabc is
        port (
        clk         : in std_logic;
        rst         : in std_logic;
        constanteIn : in unsigned(7 downto 0); -- constante a ser escrita
        reg_r       : in unsigned(3 downto 0); -- qual reg selecionado
        wr_en_reg   : in std_logic;
        eh_I        : in std_logic; -- se é uma instrução de I
        eh_LI       : in std_logic; -- se é uma instrução de LI
        eh_mv       : in std_logic; -- se é uma instrução de mv
        eh_R        : in std_logic;
        opcode      : in unsigned(3 downto 0); -- opcode da instrução
        borrow_in   : in std_logic; -- sinal de borrow para a ULA
        wr_en_ac    : in std_logic; -- write enable acumulador
        en_dataOutBK: in std_logic; -- habilita a saída do banco de registradores
        zero        : out std_logic -- sinal de zero da ULA
    );
end component;

    component ROM_pc_regInst is
    port(
        clk          : in std_logic;
        rst          : in std_logic;
        wr_en_pc     : in std_logic;
        wr_en_addPC  : in std_logic;
        wr_en_regInst: in std_logic; 
        jump_enable  : in std_logic;
        endPC_jump   : in unsigned(6 downto 0); -- endereço para o qual o PC deve pular quando jump_en = 1;
        instr_atual  : out unsigned(15 downto 0) -- dado atual da rom sai do registrador de instruções
    );
end component;

    component UC is
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
        constante   : out unsigned(7 downto 0);     -- OK
        qual_reg    : out unsigned(3 downto 0);     -- OK
        eh_mv       : out std_logic;
        wrEn_reg    : out std_logic;
        eh_R        : out std_logic;
        en_dataOutBK: out std_logic; -- zera só no comando store
        opcode      : out unsigned(3 downto 0);     -- OK
        eh_LI       : out std_logic;                -- OK
        reset_acu   : out std_logic;                -- OK
        wrEn_acu    : out std_logic
    );
end component;

--signals 
signal instruc: unsigned(15 downto 0);
signal jumpEn: std_logic;
signal jump_end: unsigned(6 downto 0);
signal val_cnte: unsigned(7 downto 0);
signal reg_esc: unsigned(3 downto 0);
signal I: std_logic;
signal li: std_logic;
signal mv: std_logic;
signal R: std_logic;
signal opc: unsigned(3 downto 0);
signal wrEnReg: std_logic;
signal enDOBK : std_logic;
signal wrEnAdd: std_logic;
signal wrEnAcu: std_logic;
signal wrEnRI : std_logic;
signal wrEnPC : std_logic;
signal resetAcu: std_logic;

begin 
    u_uabc: uabc port map(
        clk         => clk,
        rst         => rst,
        constanteIn => val_cnte,
        reg_r       => reg_esc,
        wr_en_reg   => wrEnReg,
        eh_I        => I,
        eh_LI       => li,
        eh_mv       => mv,
        eh_R        => R,
        opcode      => opc,
        borrow_in   => '0', -- dps mudamos
        wr_en_ac    => wrEnAcu,
        en_dataOutBK=> enDOBK,
        zero        => zero
    );

    urpcr: ROM_pc_regInst port map(
        clk          => clk,
        rst          => rst,
        wr_en_pc     => wrEnPC,
        wr_en_addPC  => wrEnAdd,
        wr_en_regInst=> wrEnRI,
        jump_enable  => jumpEn,
        endPC_jump   => jump_end,
        instr_atual  => instruc
    );

    uuc: UC port map(
        clk         => clk,
        rst         => rst,
        instrucao   => instruc,
        jump_adrss  => jump_end,
        jump_en     => jumpEn,
        wrEn_addPC  => wrEnAdd,
        wrEn_PC     => wrEnPC,
        wrEn_RI     => wrEnRI,
        eh_I        => I,
        constante   => val_cnte,
        qual_reg    => reg_esc,
        eh_mv       => mv,
        eh_R        => R,
        wrEn_reg    => wrEnReg,
        en_dataOutBK=> enDOBK,
        opcode      => opc,
        eh_LI       => li,
        reset_acu   => resetAcu,
        wrEn_acu    => wrEnAcu
    );

end architecture;