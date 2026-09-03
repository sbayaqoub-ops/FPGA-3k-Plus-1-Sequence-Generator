library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity three_k_plus_one is
 port(
 reset : in std_logic;
 clk_in : in std_logic;
 an : out std_logic_vector(7 downto 0);
 sseg : out std_logic_vector(7 downto 0);
 done_out : out std_logic
 );
end three_k_plus_one;
architecture rtl of three_k_plus_one is
 signal number_reg : unsigned(6 downto 0);
 signal term_reg : unsigned(6 downto 0);
 signal length_reg : unsigned(3 downto 0);
 signal done_reg : std_logic;
 signal count_1hz : unsigned(26 downto 0);
 signal tick_1hz : std_logic;
 signal count_scan : unsigned(13 downto 0);
 signal tick_scan : std_logic;
 signal scan_digit : unsigned(2 downto 0);
signal hex_digit : std_logic_vector(3 downto 0);
 function hex_to_sseg(x : std_logic_vector(3 downto 0)) return
std_logic_vector is
 begin
 case x is
 when "0000" => return "00000011";
 when "0001" => return "10011111";
 when "0010" => return "00100101";
 when "0011" => return "00001101";
 when "0100" => return "10011001";
 when "0101" => return "01001001";
 when "0110" => return "01000001";
 when "0111" => return "00011111";
 when "1000" => return "00000001";
 when "1001" => return "00001001";
 when "1010" => return "00010001";
 when "1011" => return "11000001";
 when "1100" => return "01100011";
 when "1101" => return "10000101";
 when "1110" => return "01100001";
 when others => return "01110001";
 end case;
 end function;
begin
 done_out <= done_reg;
 process(clk_in, reset)
 begin
   if reset = '1' then
 count_1hz <= (others => '0');
 tick_1hz <= '0';
 elsif clk_in'event and clk_in = '1' then
 if count_1hz = to_unsigned(99999999, count_1hz'length) then
 count_1hz <= (others => '0');
 tick_1hz <= '1';
 else
 count_1hz <= count_1hz + 1;
 tick_1hz <= '0';
 end if;
 end if;
 end process;
 process(clk_in, reset)
 variable next_number : unsigned(6 downto 0);
 begin
 if reset = '1' then
 number_reg <= to_unsigned(1, 7);
 term_reg <= to_unsigned(1, 7);
 length_reg <= to_unsigned(1, 4);
 done_reg <= '0';
 elsif clk_in'event and clk_in = '1' then
 if tick_1hz = '1' then
 if done_reg = '0' then
 if term_reg = to_unsigned(1, 7) then
 if length_reg >= to_unsigned(9, 4) then
 done_reg <= '1';
 else
 next_number := number_reg + 1;
                            number_reg <= next_number;
term_reg <= next_number;
length_reg <= to_unsigned(1, 4);
 end if;
 else
 if term_reg(0) = '0' then
 term_reg <= shift_right(term_reg, 1);
 else
 term_reg <= resize((term_reg *
to_unsigned(3, 7)) + to_unsigned(1, 14), 7);
 end if;
 length_reg <= length_reg + 1;
 end if;
 end if;
 end if;
 end if;
 end process;
 process(clk_in, reset)
 begin
 if reset = '1' then
 count_scan <= (others => '0');
 tick_scan <= '0';
 scan_digit <= (others => '0');
 elsif clk_in'event and clk_in = '1' then
 if count_scan = to_unsigned(12499, count_scan'length) then
 count_scan <= (others => '0');
 tick_scan <= '1';
 scan_digit <= scan_digit + 1;
 else
 count_scan <= count_scan + 1;
                             tick_scan <= '0';
 end if;
 end if;
 end process;
 process(scan_digit, term_reg, number_reg)
 begin
 an <= "11111111";
 hex_digit <= "0000";
 case scan_digit is
 when "000" =>
 an <= "11111110";
 hex_digit <= std_logic_vector(term_reg(3 downto 0));
 when "001" =>
 an <= "11111101";
 hex_digit <= '0' & std_logic_vector(term_reg(6 downto
4));
 when "010" =>
 an <= "11111011";
 hex_digit <= '0' & std_logic_vector(number_reg(2 downto
0));
 when others =>
 an <= "11111111";
 hex_digit <= "0000";
 end case;
 end process;
                             sseg <= hex_to_sseg(hex_digit);
end rtl;
