library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula_acu_tb is
end entity;

architecture sim of ula_acu_tb is

    component ula_acu is
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            dataInULA   : in unsigned(15 downto 0);
            dataInAcu   : in unsigned(15 downto 0);
            opcode      : in unsigned(3 downto 0);
            borrow_in   : in std_logic;
            load_regAcu : in std_logic;
            wr_en_ac    : in std_logic;
            dadoCalc    : out unsigned(15 downto 0);
            zero        : out std_logic
        );
    end component;

    -- Sinais de entrada
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '0';
    signal dataInULA    : unsigned(15 downto 0) := (others => '0');
    signal dataInAcu    : unsigned(15 downto 0) := (others => '0');
    signal opcode       : unsigned(3 downto 0) := (others => '0');
    signal borrow_in    : std_logic := '0';
    signal load_regAcu  : std_logic := '0';
    signal wr_en_ac     : std_logic := '0';
    
    -- Sinais de saída
    signal dadoCalc     : unsigned(15 downto 0);
    signal zero         : std_logic;
    
    -- Clock period
    constant clock_period : time := 10 ns;

begin

    uut: ula_acu
        port map(
            clk         => clk,
            rst         => rst,
            dataInULA   => dataInULA,
            dataInAcu   => dataInAcu,
            opcode      => opcode,
            borrow_in   => borrow_in,
            load_regAcu => load_regAcu,
            wr_en_ac    => wr_en_ac,
            dadoCalc    => dadoCalc,
            zero        => zero
        );

    -- Processo para gerar o clock
    clock_process: process
    begin
        clk <= '0';
        wait for clock_period/2;
        clk <= '1';
        wait for clock_period/2;
    end process;

    -- Processo de teste principal
    stim_proc: process
    begin
        -- Inicialização e reset
        report "Iniciando teste..." severity note;
        rst <= '1';
        wait for clock_period;
        rst <= '0';
        wait for clock_period;
        
        -- Teste 1: Carregar valor diretamente no acumulador (modo load)
        report "Teste 1: Carregando valor 5 diretamente no acumulador" severity note;
        dataInAcu <= to_unsigned(5, 16);
        load_regAcu <= '1';
        wr_en_ac <= '1';
        opcode <= "0011";
        wait for clock_period;
        load_regAcu <= '0';
        wr_en_ac <= '0';
        wait for clock_period;
        
        -- Verificar saída da ULA (deve ser 5, pois não houve operação)
        assert dadoCalc = to_unsigned(5, 16) 
            report "Falha no Teste 1: Valor no acumulador incorreto" severity error;
        
        -- Teste 2: Operação de soma (5 + 3 = 8)
        report "Teste 2: Operação de soma (5 + 3 = 8)" severity note;
        dataInULA <= to_unsigned(3, 16);
        opcode <= "1111"; -- soma
        wr_en_ac <= '1';
        wait for clock_period;
        wr_en_ac <= '0';
        wait for clock_period;
        
        assert dadoCalc = to_unsigned(8, 16) 
            report "Falha no Teste 2: Resultado da soma incorreto" severity error;
        
        -- Teste 3: Operação de subtração (8 - 2 = 6)
        report "Teste 3: Operação de subtração (8 - 2 = 6)" severity note;
        dataInULA <= to_unsigned(2, 16);
        opcode <= "0001"; -- subtração
        borrow_in <= '0';
        wr_en_ac <= '1';
        wait for clock_period;
        wr_en_ac <= '0';
        wait for clock_period;
        
        assert dadoCalc = to_unsigned(6, 16) 
            report "Falha no Teste 3: Resultado da subtração incorreto" severity error;
        
        -- Teste 4: Verificar flag zero (6 != 0)
        report "Teste 4: Verificando flag zero (6 != 0)" severity note;
        wait for clock_period;
        assert zero = '0' report "Falha no Teste 4: Flag zero ativada incorretamente" severity error;
        
        -- Teste 5: Operação que resulta em zero (6 - 6 = 0)
        report "Teste 5: Operação que resulta em zero (6 - 6 = 0)" severity note;
        dataInULA <= to_unsigned(6, 16);
        opcode <= "0001"; -- Subtração
        wr_en_ac <= '1';
        wait for clock_period;
        wr_en_ac <= '0';
        wait for clock_period;
        
        assert dadoCalc = to_unsigned(0, 16) 
            report "Falha no Teste 5: Resultado deveria ser zero" severity error;
        assert zero = '1' report "Falha no Teste 5: Flag zero não ativada" severity error;
        
        -- Teste 6: Carregar novo valor diretamente no acumulador (substituindo o zero)
        report "Teste 6: Carregando valor 10 diretamente no acumulador" severity note;
        dataInAcu <= to_unsigned(10, 16);
        load_regAcu <= '1';
        wr_en_ac <= '1';
        wait for clock_period;
        load_regAcu <= '0';
        wr_en_ac <= '0';
        wait for clock_period;
        
        assert dadoCalc = to_unsigned(10, 16) 
            report "Falha no Teste 6: Valor no acumulador incorreto" severity error;
        assert zero = '0' report "Falha no Teste 6: Flag zero ainda ativada" severity error;
        

        assert dadoCalc = to_unsigned(2, 16) 
            report "Falha no Teste 7: Resultado do AND incorreto" severity error;
        
        -- Finalização
        report "Teste concluído com sucesso!" severity note;
        wait;
    end process;

end architecture;