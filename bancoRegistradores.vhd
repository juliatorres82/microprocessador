library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bancoRegistradores is
    port (
        clk     : in std_logic;
        rst     : in std_logic;
        wr_en   : in std_logic;
        reg_r   : in unsigned(3 downto 0); --seletor de QUAL REG será usado (só precisa de 4 bits pq vai de 0 a 9)
        en_dataOutBK: in std_logic; -- habilita a saída do banco de registradores
        data_wr : in unsigned(15 downto 0); 
        data_out: out unsigned(15 downto 0) --DADO do reg escolhido
    );
end entity;

architecture a_bancoRegistradores of bancoRegistradores is 

    --declara a variavel registrador
    component registrador is
        port (
            clk     : in std_logic;
            rst     : in std_logic;
            wr_en   : in std_logic;
            data_in : in unsigned(15 downto 0); 
            data_out: out unsigned(15 downto 0)
        );
    end component;

    --sinais q sairão de cada registrador
    signal r0, r1, r2, r3, r4, r5, r6, r7, r8, r9: unsigned(15 downto 0);
    signal wr_en0, wr_en1, wr_en2, wr_en3, wr_en4, wr_en5, wr_en6, wr_en7, wr_en8, wr_en9: std_logic;

begin
    --enable so p quem for selecionado
    wr_en0 <= wr_en when reg_r = "0000" else '0';
    wr_en1 <= wr_en when reg_r = "0001" else '0';
    wr_en2 <= wr_en when reg_r = "0010" else '0';
    wr_en3 <= wr_en when reg_r = "0011" else '0';
    wr_en4 <= wr_en when reg_r = "0100" else '0';
    wr_en5 <= wr_en when reg_r = "0101" else '0';
    wr_en6 <= wr_en when reg_r = "0110" else '0';
    wr_en7 <= wr_en when reg_r = "0111" else '0';
    wr_en8 <= wr_en when reg_r = "1000" else '0';
    wr_en9 <= wr_en when reg_r = "1001" else '0';

    --instancia 10 regs e permite selecionar UM deles para Manipular
    reg0: registrador port map(clk => clk, rst => rst, wr_en => wr_en0, data_in => data_wr, data_out => r0);
    reg1: registrador port map(clk => clk, rst => rst, wr_en => wr_en1, data_in => data_wr, data_out => r1);
    reg2: registrador port map(clk => clk, rst => rst, wr_en => wr_en2, data_in => data_wr, data_out => r2);
    reg3: registrador port map(clk => clk, rst => rst, wr_en => wr_en3, data_in => data_wr, data_out => r3);
    reg4: registrador port map(clk => clk, rst => rst, wr_en => wr_en4, data_in => data_wr, data_out => r4);
    reg5: registrador port map(clk => clk, rst => rst, wr_en => wr_en5, data_in => data_wr, data_out => r5);
    reg6: registrador port map(clk => clk, rst => rst, wr_en => wr_en6, data_in => data_wr, data_out => r6);
    reg7: registrador port map(clk => clk, rst => rst, wr_en => wr_en7, data_in => data_wr, data_out => r7);
    reg8: registrador port map(clk => clk, rst => rst, wr_en => wr_en8, data_in => data_wr, data_out => r8);
    reg9: registrador port map(clk => clk, rst => rst, wr_en => wr_en9, data_in => data_wr, data_out => r9);
       
    
    --agr os sinais foram criados, falta mandar o sinal p saída;
    data_out <= r0 when reg_r = "0000" and en_dataOutBK = '1' else
                r1 when reg_r = "0001" and en_dataOutBK = '1' else
                r2 when reg_r = "0010" and en_dataOutBK = '1' else
                r3 when reg_r = "0011" and en_dataOutBK = '1' else
                r4 when reg_r = "0100" and en_dataOutBK = '1' else
                r5 when reg_r = "0101" and en_dataOutBK = '1' else
                r6 when reg_r = "0110" and en_dataOutBK = '1' else
                r7 when reg_r = "0111" and en_dataOutBK = '1' else
                r8 when reg_r = "1000" and en_dataOutBK = '1' else
                r9 when reg_r = "1001" and en_dataOutBK = '1' else
                "0000000000000000"; 
end architecture;