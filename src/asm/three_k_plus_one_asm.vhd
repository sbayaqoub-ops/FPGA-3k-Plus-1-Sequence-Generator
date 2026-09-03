library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity three_k_plus_one is
    port(
        reset    : in std_logic;
        clk_in   : in std_logic;
        an       : out std_logic_vector(7 downto 0);
        sseg     : out std_logic_vector(7 downto 0);
        done_out : out std_logic
    );
end three_k_plus_one;

architecture asm_rtl of three_k_plus_one is

    constant ONE_HZ_MAX : natural := 4;
    constant SCAN_MAX   : natural := 12499;

    type state_type is (
        reset_state,
        increment_number,
        load_term_state,
        test_term_state,
        check_length_state,
        test_even_state,
        divide_term_state,
        mult_add_state,
        done_state
    );

    signal state_reg, state_next : state_type;

    signal number_reg : unsigned(6 downto 0);
    signal term_reg   : unsigned(6 downto 0);
    signal length_reg : unsigned(3 downto 0);
    signal done_reg   : std_logic;

    signal count_1hz : unsigned(26 downto 0);
    signal tick_1hz  : std_logic;

    signal count_scan : unsigned(13 downto 0);
    signal scan_digit : unsigned(2 downto 0);

    signal reset_number  : std_logic;
    signal inc_number    : std_logic;
    signal reset_term    : std_logic;
    signal load_term     : std_logic;
    signal shift_term    : std_logic;
    signal mult_add_term : std_logic;
    signal reset_length  : std_logic;
    signal inc_length    : std_logic;
    signal reset_done    : std_logic;
    signal load_done     : std_logic;

    signal term_eq_1   : std_logic;
    signal term_even   : std_logic;
    signal length_ge_9 : std_logic;

    signal hex_digit : std_logic_vector(3 downto 0);

begin

    done_out <= done_reg;

    term_eq_1 <= '1'
        when term_reg = to_unsigned(1, 7)
        else '0';

    term_even <= '1'
        when term_reg(0) = '0'
        else '0';

    length_ge_9 <= '1'
        when length_reg >= to_unsigned(9, 4)
        else '0';

    process(clk_in, reset)
    begin
        if reset = '1' then
            count_1hz <= (others => '0');
            tick_1hz <= '0';

        elsif clk_in'event and clk_in = '1' then

            if count_1hz =
                to_unsigned(ONE_HZ_MAX, count_1hz'length) then

                count_1hz <= (others => '0');
                tick_1hz <= '1';

            else
                count_1hz <= count_1hz + 1;
                tick_1hz <= '0';
            end if;

        end if;
    end process;


    process(clk_in, reset)
    begin
        if reset = '1' then
            state_reg <= reset_state;

        elsif clk_in'event and clk_in = '1' then

            if tick_1hz = '1' then
                state_reg <= state_next;
            end if;

        end if;
    end process;


    process(state_reg, term_eq_1, term_even, length_ge_9)
    begin

        state_next <= state_reg;

        reset_number <= '0';
        inc_number <= '0';

        reset_term <= '0';
        load_term <= '0';
        shift_term <= '0';
        mult_add_term <= '0';

        reset_length <= '0';
        inc_length <= '0';

        reset_done <= '0';
        load_done <= '0';

        case state_reg is

            when reset_state =>
                reset_number <= '1';
                reset_term <= '1';
                reset_length <= '1';
                reset_done <= '1';

                state_next <= increment_number;


            when increment_number =>
                inc_number <= '1';

                state_next <= load_term_state;


            when load_term_state =>
                load_term <= '1';
                reset_length <= '1';

                state_next <= test_term_state;


            when test_term_state =>

                if term_eq_1 = '1' then
                    state_next <= check_length_state;
                else
                    state_next <= test_even_state;
                end if;


            when check_length_state =>

                if length_ge_9 = '1' then
                    state_next <= done_state;
                else
                    state_next <= increment_number;
                end if;


            when test_even_state =>

                if term_even = '1' then
                    state_next <= divide_term_state;
                else
                    state_next <= mult_add_state;
                end if;


            when divide_term_state =>
                shift_term <= '1';
                inc_length <= '1';

                state_next <= test_term_state;


            when mult_add_state =>
                mult_add_term <= '1';
                inc_length <= '1';

                state_next <= test_term_state;


            when done_state =>
                load_done <= '1';

                state_next <= done_state;

        end case;

    end process;


    process(clk_in, reset)
    begin
        if reset = '1' then
            number_reg <= to_unsigned(1, 7);

        elsif clk_in'event and clk_in = '1' then

            if tick_1hz = '1' then

                if reset_number = '1' then
                    number_reg <= to_unsigned(1, 7);

                elsif inc_number = '1' then
                    number_reg <= number_reg + 1;
                end if;

            end if;

        end if;
    end process;


    process(clk_in, reset)
    begin
        if reset = '1' then
            term_reg <= to_unsigned(1, 7);

        elsif clk_in'event and clk_in = '1' then

            if tick_1hz = '1' then

                if reset_term = '1' then
                    term_reg <= to_unsigned(1, 7);

                elsif load_term = '1' then
                    term_reg <= number_reg;

                elsif shift_term = '1' then
                    term_reg <= shift_right(term_reg, 1);

                elsif mult_add_term = '1' then
                    term_reg <= resize(
                        (term_reg * to_unsigned(3, 7))
                        + to_unsigned(1, 14), 7
                    );
                end if;

            end if;

        end if;
    end process;


    process(clk_in, reset)
    begin
        if reset = '1' then
            length_reg <= to_unsigned(1, 4);

        elsif clk_in'event and clk_in = '1' then

            if tick_1hz = '1' then

                if reset_length = '1' then
                    length_reg <= to_unsigned(1, 4);

                elsif inc_length = '1' then
                    length_reg <= length_reg + 1;
                end if;

            end if;

        end if;
    end process;


    process(clk_in, reset)
    begin
        if reset = '1' then
            done_reg <= '0';

        elsif clk_in'event and clk_in = '1' then

            if tick_1hz = '1' then

                if reset_done = '1' then
                    done_reg <= '0';

                elsif load_done = '1' then
                    done_reg <= '1';
                end if;

            end if;

        end if;
    end process;


    process(clk_in, reset)
    begin
        if reset = '1' then
            count_scan <= (others => '0');
            scan_digit <= (others => '0');

        elsif clk_in'event and clk_in = '1' then

            if count_scan =
                to_unsigned(SCAN_MAX, count_scan'length) then

                count_scan <= (others => '0');
                scan_digit <= scan_digit + 1;

            else
                count_scan <= count_scan + 1;
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
                hex_digit <= std_logic_vector(
                    term_reg(3 downto 0)
                );

            when "001" =>
                an <= "11111101";
                hex_digit <= '0' &
                    std_logic_vector(term_reg(6 downto 4));

            when "010" =>
                an <= "11111011";
                hex_digit <=
                    std_logic_vector(number_reg(3 downto 0));

            when others =>
                an <= "11111111";
                hex_digit <= "0000";

        end case;

    end process;


    process(hex_digit)
    begin

        case hex_digit is

            when "0000" => sseg <= "00000011";
            when "0001" => sseg <= "10011111";
            when "0010" => sseg <= "00100101";
            when "0011" => sseg <= "00001101";
            when "0100" => sseg <= "10011001";
            when "0101" => sseg <= "01001001";
            when "0110" => sseg <= "01000001";
            when "0111" => sseg <= "00011111";
            when "1000" => sseg <= "00000001";
            when "1001" => sseg <= "00001001";
            when "1010" => sseg <= "00010001";
            when "1011" => sseg <= "11000001";
            when "1100" => sseg <= "01100011";
            when "1101" => sseg <= "10000101";
            when "1110" => sseg <= "01100001";
            when others => sseg <= "01110001";

        end case;

    end process;

end asm_rtl;
