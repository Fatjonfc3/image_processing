

library IEEE;

use IEEE.numeric_Std.all;
use IEEE.std_logic_1164.all;

package helper is

type t_data_in is array ( 0 to 2 ) of unsigned(48 - 1 downto 0  ) ; -- 16*3 - 1 we suppose we get immediately 3 pixels of each row, so in total of 9 pixels, I don't like it as an implementation , but trying to be compliant to the requirements


end package helper;

entity MAC is 
generic
(
)
port (
 i_clk , i_rst : in std_logic;
 i_data : in t_data_in := ( others => ( others => '0') );
 i_data_valid : in std_logic;
 o_data : out std_logic_vector ( 15 downto 0 );
 o_data_valid : out std_logic;

);

end entity MAC;

architecture rtl of MAC is
type t_kernel_coeff is array ( 0 to 3 ) of unsigned ( 7 downto 0 ); 
type t_kernel_all is array ( 0 to 3 ) of t_kernel_coeff ; -- just some types to make possible faster code with for loop but in hw nothing 								changes
signal kernel_coeff  : t_kernel_all ;

type t_mult_result is array ( 0 to 3) of unsigned ( 23 downto 0 );
type t_mult_all is array ( 0 to 3) of t_mult_Result;
signal mul_reg : t_mult_all := (others => ( others => ( others => '0')));

begin
init_coeff_Value : for I in 0 to 2 generate --just lazy today to write the init at the signal declaration, requirement the kernel is just a normal moving average blurring all 1/8
	for j in  0 to 2  generate
	kernel_coeff ( I ) ( j )<= to_unsigned (1 , kernel_coeff(I)'length);
	end generate;
end generate init_coeff_Value;

mult_process : process ( i_clk , i_rst )
begin
 	if rising_edge ( clk) then
		for I in 0 to 2 loop -- supposing a 3x3 kernel just for simplicity , todo: put those as generics
			for j in 0 to 2 loop
			mult_reg ( i ) ( j ) <=  i_data (i) (j*16 + 16 - 1 downto j*16) * kernel_coeff (I)(j); -- supposing the first value written at first 8 bits , 9 dsp multipliers would be inferred looks a bit to much in my opinion, but the requirements inferred so
			end loop;
		end loop;
		stage_1_Valid <= i_data_Valid;

end process mult_process;

addition_tree_1 : process ( i_clk , i_rst)
begin
	if rising_edge ( clk ) then
		for i in 0 to 2 loop
			add_tree_first ( i ) <= mult_reg (0)(i) + mult_reg (1)(i);
		end loop;
		add_tree ( 3 ) <= mult_reg (2)(0) + mult_reg(2) (1);
		stage_2_valid <= stage_1_valid;
		--TODO Declare the intermediate adder signals 
		for i in 0 to 1 loop
			add_tree_second ( i ) <= add_tree_first (i ) + add_tree_first ( i + 2)
		end loop;
		stage_3_valid <= stage_2_Valid;

		add_tree_third  <= add_tree_Second (0) + add_tree_second (1)
		stage_4_valid <= stage_3_valid;
		
		final_add <= add_three_third + mult_reg (2)(2)
		stage_5_valid <= stage_4_Valid;
		final_add_rounded <= final_add ((x downto 3 => '0') & final_add_rounded(3) & "11");
		stage_6_valid <= stage_5_valid;
		o_data_reg <= final_add_rounded srl 3;
		final_valid <= stage_6_valid; 
	end if;
end process addition_Tree_1

o_data <= o_data_reg (15 downto 0 ) ; -- because even though we tried a general use case in fact we will be just adding all the 16 bits so
					-- at max it can grow to 20 bit if all values the same , then we right shigt by 3 so 17 bit
o_valid <= final_valid

end architecture rtl;
