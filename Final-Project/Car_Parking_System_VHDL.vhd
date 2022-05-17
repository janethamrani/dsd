library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
entity Car_Parking_System_VHDL is
port 
(
  clk,reset_n: in std_logic; -- clock and reset of the car parking system
  front_sensor, back_sensor: in std_logic; -- two sensor in front and behind the gate of the car parking system
  GREEN_LED,RED_LED: out std_logic; -- signaling LEDs
  bt_clr : IN STD_LOGIC; -- clear password (to change password)
  bt_eq : IN STD_LOGIC; -- set password 
  bt_submit : IN STD_LOGIC; -- submit guess password
  SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of eight 7-seg displays
  SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0); -- common segments of 7-seg displays
  KB_col : OUT STD_LOGIC_VECTOR (4 DOWNTO 1); -- keypad column pins
  KB_row : IN STD_LOGIC_VECTOR (4 DOWNTO 1)); -- keypad row pins
  

end Car_Parking_System_VHDL;

architecture Behavioral of Car_Parking_System_VHDL is

COMPONENT keypad IS
		PORT (
			samp_ck : IN STD_LOGIC;
			col : OUT STD_LOGIC_VECTOR (4 DOWNTO 1);
			row : IN STD_LOGIC_VECTOR (4 DOWNTO 1);
			value : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			hit : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT leddec16 IS
		PORT (
			dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END COMPONENT;
	
-- FSM States
--type FSM_States is (IDLE,WAIT_PASSWORD,WRONG_PASS,RIGHT_PASS,STOP);
--signal current_state,next_state: FSM_States;
signal counter_wait: std_logic_vector(31 downto 0);
signal red_tmp, green_tmp: std_logic;
SIGNAL cnt : std_logic_vector(20 DOWNTO 0); -- counter to generate timing signals
SIGNAL kp_clk, kp_hit, sm_clk : std_logic;
SIGNAL kp_value : std_logic_vector (3 DOWNTO 0);
SIGNAL nx_pass, pass : std_logic_vector (1 DOWNTO 0); --  set password number (actual password of car)
SIGNAL nx_guess, guess : std_logic_vector (1 DOWNTO 0); -- accumulated sum
--SIGNAL nx_operand, operand : std_logic_vector (15 DOWNTO 0); -- operand =
SIGNAL display : std_logic_vector (15 DOWNTO 0); -- value to be displayed
SIGNAL led_mpx : STD_LOGIC_VECTOR (2 DOWNTO 0); -- 7-seg multiplexing clock
SIGNAL data2 : STD_LOGIC_VECTOR (1 DOWNTO 0); -- binary value of current digit leddec
TYPE state IS (GUESS_PASS, SET_PASS, PASS_RELEASE, GUESS_RELEASE, SHOW_PASS, IDLE,WAIT_PASSWORD,WRONG_PASS,RIGHT_PASS,STOP); -- state machine states
SIGNAL pr_state, nx_state : state; -- present and next states

begin
-- Sequential circuits
process(clk,reset_n)
begin
 if(reset_n='0') then
  pr_state <= IDLE;
 elsif(rising_edge(clk)) then
  pr_state <= nx_state;
  cnt <= cnt + 1; -- increment counter
  kp_clk <= cnt(15); -- keypad interrogation clock
  sm_clk <= cnt(20); -- state machine clock
  led_mpx <= cnt(19 DOWNTO 17); -- 7-seg multiplexing clock
 end if;
end process;


	kp1 : keypad
	PORT MAP(
		samp_ck => kp_clk, col => KB_col, 
		row => KB_row, value => kp_value, hit => kp_hit
		);
		led1 : leddec16
		PORT MAP(
			dig => led_mpx, data => display, 
			anode => SEG7_anode, seg => SEG7_seg
		);
-- combinational logic

sm_ck_pr : PROCESS (bt_clr, sm_clk) -- state machine clock process / clear password
	BEGIN
		IF bt_clr = '1' THEN -- signal to reset password
			pass <= X"00"; -- current password
			pr_state <= SET_PASS;
		ELSIF rising_edge (sm_clk) THEN -- on rising clock edge
			pr_state <= nx_state; -- update present state
		END IF;
	END PROCESS;
sm_comb_pr : PROCESS (kp_hit, kp_value, bt_eq, pass, pr_state)
		BEGIN
			display <= data2; --set display to inputted data
			CASE pr_state IS -- depending on present state...
				WHEN SET_PASS => -- waiting for password to be set
					IF data2 /= 0 THEN -- password is inputted
						pass <= data2(1 DOWNTO 0); --set pass to data on switch
						nx_state <= PASS_RELEASE;
					ELSIF bt_eq = '1' THEN --password is set once equal button pressed
						pass <= data2(1 downto 0);
						nx_state <= IDLE; 
					ELSE
						nx_state <= SET_PASS;
					END IF;
				WHEN PASS_RELEASE => -- loop waiting for button to be pressed
					IF bt_eq = '0' THEN
						nx_state <= SET_PASS;
					ELSE nx_state <= IDLE;
					END IF;
			END CASE;
		END PROCESS;
		
		
		
		
		
process(pr_state,front_sensor,guess,pass,back_sensor,counter_wait)
 begin
 case pr_state is 
 when IDLE =>
 if(front_sensor = '1') then -- if the front sensor is on,
 -- there is a car going to the gate
  nx_state <= WAIT_PASSWORD;-- wait for password
 else
  nx_state <= IDLE;
 end if;
 when WAIT_PASSWORD => -- time to input password guess
 if(bt_submit = '0') then
    nx_guess <= guess;
    display <= guess;
  
    IF kp_hit = '1' THEN
			nx_guess <= guess(1 downto 0) & kp_value;
			nx_state <= GUESS_RELEASE; -- wait for button to be released
	ELSE
			nx_state <= WAIT_PASSWORD;
	END IF;
 else nx_state <= GUESS_PASS;
 END IF;
 
 WHEN GUESS_RELEASE => -- waiting for button to be released
		IF (kp_hit = '0') THEN
				nx_state <= WAIT_PASSWORD;
		ELSE nx_state <= GUESS_RELEASE;
		END IF;
  
  
 when GUESS_PASS => -- check password after 4 clock cycles
     if((pass="01")and(guess="10")) then
     nx_state <= RIGHT_PASS; -- if password is correct, let them in
     else
     nx_state <= WRONG_PASS; -- if not, tell them wrong pass by blinking Green LED
     -- let them input the password again
     end if;

 when WRONG_PASS =>
  
    nx_state <= WAIT_PASSWORD;-- guess password again
  
 when RIGHT_PASS =>
  if(front_sensor='1' and back_sensor = '1') then
 nx_state <= WAIT_PASSWORD; 
 -- if the gate is opening for the current car, and the next car come, 
 -- STOP the next car and require password
 -- the current car going into the car park
  elsif(back_sensor= '1') then
   -- if the current car passed the gate an going into the car park
   -- and there is no next car, go to IDLE
 nx_state <= IDLE;
  else
 nx_state <= RIGHT_PASS;
  end if;

 when others => nx_state <= IDLE;
 end case;
 end process;
 -- wait for password
process(clk,reset_n)
 begin
 if(reset_n='0') then
 counter_wait <= (others => '0');
 elsif(rising_edge(clk))then
  if(pr_state=WAIT_PASSWORD)then
  counter_wait <= counter_wait + x"00000001";
  else 
  counter_wait <= (others => '0');
  end if;
 end if;
 end process;
 -- output 
 process(clk) -- change this clock to change the LED blinking period
 begin
 if(rising_edge(clk)) then
 case(pr_state) is
 when IDLE => 
 green_tmp <= '0';
 red_tmp <= '0';
 SEG7_seg <= "1111111"; -- off
 SEG7_anode <= "1111111"; -- off
 when WAIT_PASSWORD =>
 green_tmp <= '0';
 red_tmp <= '1'; 
 -- RED LED turn on and Display 7-segment LED as EN to let the car know they need to input password
 SEG7_seg <= "0000110"; -- E 
 SEG7_anode <= "0101011"; -- n 
 when WRONG_PASS =>
 green_tmp <= '0'; -- if password is wrong, RED LED blinking 
 red_tmp <= not red_tmp;
 SEG7_seg <= "0000110"; -- E
 SEG7_anode <= "0000110"; -- E 
 when RIGHT_PASS =>
 green_tmp <= not green_tmp;
 red_tmp <= '0'; -- if password is correct, GREEN LED blinking
 SEG7_seg <= "0000010"; -- 6
 SEG7_anode <= "1000000"; -- 0 
 when STOP =>
 green_tmp <= '0';
 red_tmp <= not red_tmp; -- Stop the next car and RED LED blinking
 SEG7_seg <= "0010010"; -- 5
 SEG7_anode <= "0001100"; -- P 
 when others => 
 green_tmp <= '0';
 red_tmp <= '0';
 SEG7_seg <= "1111111"; -- off
 SEG7_anode <= "1111111"; -- off
  end case;
 end if;
 end process;
  RED_LED <= red_tmp  ;
  GREEN_LED <= green_tmp;

end Behavioral;
