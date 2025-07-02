library IEEE;

use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity Control is
generic (
	STRIDE : integer := 3;
);
port(
	clk , rst : in std_logic;
	valid_in : in std_logic;
	wr_e : out std_logic_Vector ( 3 downto 0);
	rd_e : out std_logic_vector ( 3 downto 0 )
);

architecture rtl of Control is

signal x_count : unsigned (8 downto 0) := ( others => '0'); --considering 520 pixels
signal start , pause : std_logic := '0' ;
signal  rd_e_reg : std_logic_vector (3 downto 0) := "0111";
signal wr_e_reg : std_logic_vector ( 3 downto 0) := "0001";
begin

process ( clk , rst)
begin
	if rising_edge ( clk ) then
		if x_count = 520 - 1 then
			if  start = '1' then
				rd_e_reg <= rd_e_reg ( 2 downto 0) & rd_e_reg (3);
			end if;
			wr_e_reg <= wr_e_reg (2 downto 0 ) & wr_e_reg(3);
		end if;
	end if;
end process;

process ( clk , rst)
begin
	if rising_edge ( clk ) then
		if start = '0' and wr_e_reg = "0100" and x_count = 520 - 1 then
			start <= '1' ; --just the beginning we will need to wait till the first 3 lines are fully written
		end if;
	end if;
end process;

process ( clk , rst)
begin
	if rising_edge ( clk ) then
		if start = '1' and x_count < 520/STRIDE  then
			stop <= '0';
		else
			stop <= '1';
		end if;
	end if; --if the stride is not 1 then since we add pixels one in a time but take out 3 pixels and advance with a stride different from 1
		-- there would be some period where no more data would be readen , or they would be not valid
	
end process;
valid <= not stop;
wr_e <= wr_e_Reg;
rd_e <= rd_e_reg when start ='1' else
	( others => '0');



end architecture rtl;
