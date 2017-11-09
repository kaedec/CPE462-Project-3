LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.alarm_clock_package.ALL;

ENTITY alarm_clock_tb IS
END alarm_clock_tb;

ARCHITECTURE alarm_clock_tb_arch OF alarm_clock_tb IS

COMPONENT alarm_clock
	PORT(alarm_set, clock_set, hour_set, minute_set: IN STD_LOGIC; --Push buttons
		  alarm_status, reset: IN STD_LOGIC; -- Misc inputs
		  alarm: OUT STD_LOGIC; --LEDR0 Alarm Alert
		  am_pm: OUT STD_LOGIC; --LEDG8 AM/PM Indicator (Hour 00-11 = AM/LOW; Hour 12-23 = PM/HIGH);
		  hours7, hours6: OUT STD_LOGIC_VECTOR(0 TO 6); --SSD for hours
		  minutes5, minutes4: OUT STD_LOGIC_VECTOR(0 TO 6); --SSD for minutes
		  seconds3, seconds2: OUT STD_LOGIC_VECTOR(0 TO 6); --SSD for seconds
		  clock_50MHz: STD_LOGIC); --50MHz Clock
END COMPONENT;

SIGNAL clktest, intest, outtest: STD_LOGIC;

BEGIN
  U1: alarm_clock PORT MAP (intest, clktest, outtest);
  
process
	begin
		
		clktest <= '0';
		wait for 20 ns;
		
		clktest <= '1';
		wait for 20 ns;
	
end process;
	
process
	begin
		
		-- intest SEQUENCE
		intest <= '1';
		wait for 1 ms;
		intest <= '0';
		wait for 1 ms;
		intest <= '1';
		wait for 1 ms;
		intest <= '0';
		wait for 100 us;
		intest <= '1';
		wait for 1 ms;
		intest <= '0';
		wait for 20 ms;
		intest <= '1';
		wait for 1 ms;
		intest <= '0';
		wait for 100 us;
		intest <= '1';
		wait for 1 ms;
		intest <= '0';
		wait for 200 us;
		intest <= '1';
		wait for 20 ms;
		
	end process;
  
END alarm_clock_tb_arch;

