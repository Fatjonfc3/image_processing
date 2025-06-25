
library IEEE;

use IEEE.numeric_Std.all;
use IEEE.std_logic_1164.all;

package helper is
type t_line_out is array (natural range <>) of std_logic_vector ;

end package helper;
use work.helper.all;

entity lineBuffer2 is
generic (
	FILTER_LENGTH : integer := 5;
	IMAGE_WIDTH : integer := 512;
	STRIDE : integer := 1;
)
port (

	i_clk , i_rst : in std_logic;
	i_pixel_data : in std_logic_vector ( 15 downto 0 );
	i_data_valid : in std_logic;
	i_data_read : in std_logic;
	o_data_out : out t_line_out ( 0 to 2) ( 15 downto 0 )
--	o_valid : std_logic ;  --optional 
)
end entity lineBuffer2;

architecture rtl of lineBuffer2 is
type t_lineBuff is array ( 0 to IMAGE_WIDTH ) of std_logic_vector ;

signal lineBuffer_v : t_lineBuff (15 downto 0 ):= ( others => '0');
signal wr_pointer : unsigned ( integer(ceil(log2(IMAGE_WIDTH))) - 1 downto 0 ):= (others => '0');
signal rd_pointer : unsined ( integer(ceil(log2(IMAGE_WIDTH))) - 1 downto 0 ):= (others => '0');
begin

process (i_clk , i_rst )
begin
	if i_rst = '1' then --not safe implementation just an async reset but we need to do the synchronized deassertion
		rd_pointer <= 0 ;
	elseif rising_edge ( clk ) then
		if i_data_read = '1' then
			rd_pointer <= rd_pointer + STRIDE;
		end if;
	end if;

end process;

process (i_clk , i_rst )
begin
	if i_rst = '1' then --not safe implementation just an async reset but we need to do the synchronized deassertion
		wr_pointer <= 0 ;
	elseif rising_edge ( clk ) then
		if i_data_valid = '1' then
			wr_pointer <= write_pointer + 1;
		end if;
	end if;

end process;

process ( i_clk ) -- bram or memory no reset , at most write 0 to each address
begin
if rising_edge ( i_clk ) then
	if i_data_Valid = '1' then
		lineBuffer_v (to_integer ( wr_pointer)) <= i_pixel_data;
	end if;
end if;
end process;
gen_output : for I in 0 to 2 generate
o_data_out(i) <= lineBuffer_v (to_integer(wr_pointer + I )) ;
end generate;
end architecture rtl;
