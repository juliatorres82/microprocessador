library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uabc is
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        constanteIn : in unsigned(7 downto 0); -- constante a ser escrita
        reg_r       : in unsigned(3 downto 0); -- qual reg selecionado
        wr_en_reg   : in std_logic;
        eh_R        : in std_logic; -- se é uma instrução de R
        eh_I        : in std_logic; -- se é uma instrução de I
        eh_LI       : in std_logic; -- se é uma instrução de LI
        eh_mv       : in std_logic; -- se é uma instrução de mv
        opcode      : in unsigned(3 downto 0); -- opcode da instrução
        borrow_in   : in std_logic; -- sinal de borrow para a ULA
        wr_en_ac    : in std_logic; -- write enable acumulador
        en_dataOutBK: in std_logic; -- habilita a saída do banco de registradores
        zero        : out std_logic; -- sinal de zero da ULA
        dadoCalc    : out unsigned(15 downto 0)
    );
end entity;

architecture a_uabc of uabc is
    component ula_acu
        port (
            clk      : in std_logic;
            rst      : in std_logic;
            dataInULA: in unsigned(15 downto 0);
            dataInAcu: in unsigned(15 downto 0);
            opcode   : in unsigned(3 downto 0);
            borrow_in: in std_logic;
            load_regAcu: in std_logic;
            wr_en_ac : in std_logic;
            dadoCalc : out unsigned(15 downto 0);
            zero     : out std_logic
        );
    end component;

    component calcConstante
        port(
            constante   : in unsigned(7 downto 0); -- constante a ser escrita
            saida_cnte  : out unsigned(15 downto 0) -- saída da constante
     );
    end component;

    component bancoRegistradores
        port (
            clk     : in std_logic;
            rst     : in std_logic;
            wr_en   : in std_logic;
            en_dataOutBK: in std_logic; -- habilita a saída do banco de registradores
            reg_r   : in unsigned(3 downto 0); --seletor de QUAL REG será usado (só precisa de 4 bits pq vai de 0 a 9)
            data_wr : in unsigned(15 downto 0); 
            data_out: out unsigned(15 downto 0) --DADO do reg escolhido
    );
    end component;

    signal dataInULA     : unsigned(15 downto 0) := (others => '0');
    signal dataInAcu     : unsigned(15 downto 0) := (others => '0');
    signal muxInAcu      : unsigned(15 downto 0) := (others => '0');
    signal outULA        : unsigned(15 downto 0) := (others => '0');
    signal outCnte       : unsigned(15 downto 0) := (others => '0');
    signal muxdataBK     : unsigned(15 downto 0) := (others => '0');
    signal muxInULA      : unsigned(15 downto 0) := (others => '0');

    begin

        cc: calcConstante
            port map(
                constante  => constanteIn,
                saida_cnte => outCnte
            );
        
        bk: bancoRegistradores
            port map(
                clk      => clk,
                rst      => rst,
                wr_en    => wr_en_reg,
                reg_r    => reg_r,
                data_wr  => muxdataBK, 
                en_dataOutBK => en_dataOutBK,
                data_out => dataInAcu
            );
        
        uac: ula_acu
            port map(
                clk         => clk,
                rst         => rst,
                dataInULA   => muxInULA,
                dataInAcu   => muxInAcu,
                opcode      => opcode,
                borrow_in   => borrow_in,
                load_regAcu => eh_mv,
                wr_en_ac    => wr_en_ac,
                dadoCalc    => outULA,
                zero        => zero
            );

        --muxInULA <= outCnte when eh_I = '1' else (others => '0'); -- Se for uma instrução de I, usa a constante, senão, não faz nada.
        muxInULA <= dataInAcu when eh_R = '1' else outCnte when eh_I = '1' else (others => '0'); -- + saída do banco qndo inst R;
        muxdataBK <= outCnte when eh_LI = '1' else outULA;
        muxInAcu <= dataInAcu when eh_mv = '1' else outULA; -- Se for uma instrução de mv, usa o dado do banco de registradores, senão, usa o dado da ULA.
        
        dadoCalc <= outULA;
    end architecture;