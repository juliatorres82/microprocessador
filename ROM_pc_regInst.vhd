library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM_pc_regInst is
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
end entity;

architecture a_rom_pc of ROM_pc_regInst is

    component ROM is
        port(
            clk      : in std_logic;
            endereco : in unsigned(6 downto 0);
            dado     : out unsigned(15 downto 0)
        );
    end component;

    component PC is 
        port (
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(6 downto 0); 
            data_out : out unsigned(6 downto 0)
        );
    end component;

    component addPC is 
        port(
            entrada : in unsigned(6 downto 0);
            wr_en   : in std_logic;
            saida   : out unsigned(6 downto 0)
        );
    end component;

    component RegInstrucao is
        port (
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(15 downto 0); 
            data_out : out unsigned(15 downto 0)
        );
    end component;
    
    signal endereco_atual: unsigned(6 downto 0);
    signal endereco_prox : unsigned(6 downto 0);
    signal instrucao_atual: unsigned(15 downto 0);
    signal mux_inPC       : unsigned(6 downto 0); -- entrada do mux do PC

    begin
    uROM: ROM 
        port map(
            clk      => clk,
            endereco => endereco_atual, 
            dado     => instrucao_atual
        );

    uPC: PC
        port map (
            clk      => clk,
            rst      => rst,
            wr_en    => wr_en_pc,
            data_in  => mux_inPC,
            data_out => endereco_atual
        );

    uADDPC: addPC
        port map(
            entrada => endereco_atual,
            wr_en   => wr_en_addPC,
            saida   => endereco_prox
        );

    uuRI: RegInstrucao
        port map(
            clk      => clk,
            rst      => rst,
            wr_en    => wr_en_regInst,
            data_in  => instrucao_atual,
            data_out => instr_atual
        );

        mux_inPC <= endPC_jump when jump_enable = '1' else endereco_prox;
end architecture;
