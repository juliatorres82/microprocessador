library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula_acu is
    port (
        clk      : in std_logic;
        rst      : in std_logic;
        dataInULA: in unsigned(15 downto 0); -- reg1 vai para a ula
        dataInAcu: in unsigned(15 downto 0); -- dado a ser carregado no acumulador
        opcode   : in unsigned(3 downto 0);
        borrow_in: in std_logic;
        load_regAcu: in std_logic; -- load registrador no acumulador
        wr_en_ac : in std_logic; -- load
        dadoCalc : out unsigned(15 downto 0);
        zero     : out std_logic -- sinal de zero

    );
end entity;

architecture a_uac of ula_acu is
    component ULA
       port(
        acumulador_in  : in unsigned(15 downto 0);  -- dado do acumulador
        B              : in unsigned(15 downto 0);  -- dado do registrador
        opcode         : in unsigned(3 downto 0); 
        borrow_in      : in std_logic;              -- para SUBB
        outULA         : out unsigned(15 downto 0);
        zero           : out std_logic
    );
    end component;

    component acumulador
        port (
        clk     : in std_logic;
        rst     : in std_logic;
        wr_en   : in std_logic;
        data_in : in unsigned(15 downto 0); 
        data_out: out unsigned(15 downto 0)
    );
    end component;

    signal mux_acu : unsigned (15 downto 0);
    signal outAcumulador: unsigned (15 downto 0);
    signal outULA: unsigned (15 downto 0);

begin 
    uula: ULA 
        port map (
            acumulador_in  => outAcumulador,
            B              => dataInULA,
            opcode         => opcode,
            borrow_in      => borrow_in,
            outULA         => outULA,
            zero           => zero
        );

    acu: acumulador
        port map(
            clk      => clk,
            rst      => rst,
            wr_en    => wr_en_ac,
            data_in  => mux_acu,
            data_out => outAcumulador
        );

        -- mux do acumulador: se reset, zera; se load = 1, carrega dado do reg; cc, carrega resultado da ULA
    mux_acu <= 
        (others => '0') when rst = '1' else
        dataInAcu when load_regAcu = '1' else
        outULA;

    dadoCalc <= outULA; -- saída da ULA
end architecture;
