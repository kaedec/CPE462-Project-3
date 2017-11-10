LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE alarm_clock_package IS
-------------------------------------------------------------------------------
	TYPE my_time IS ARRAY (5 DOWNTO 0) OF NATURAL;
-------------------------------------------------------------------------------
	COMPONENT debounce IS
		PORT(btn, clk: IN STD_LOGIC;
				debounced: OUT STD_LOGIC);
	END COMPONENT;
-------------------------------------------------------------------------------
	FUNCTION dispSSD (SIGNAL S: NATURAL) RETURN STD_LOGIC_VECTOR;
-------------------------------------------------------------------------------	
	FUNCTION rise_edge (SIGNAL CLK: STD_LOGIC) RETURN BOOLEAN;
-------------------------------------------------------------------------------
	PROCEDURE slow_the_clock (SIGNAL ip_clock, rst: IN STD_LOGIC;
										CONSTANT divider: IN NATURAL;
										SIGNAL op_clock: OUT STD_LOGIC);
-------------------------------------------------------------------------------
	PROCEDURE clock_display (SIGNAL clock: IN STD_LOGIC;
										SIGNAL hours_tens, hours_ones,
										minutes_tens, minutes_ones,
										seconds_tens, seconds_ones: INOUT NATURAL RANGE 0 TO 9);
-------------------------------------------------------------------------------
END alarm_clock_package;

PACKAGE BODY alarm_clock_package IS
-------------------------------------------------------------------------------
	FUNCTION dispSSD (SIGNAL S: NATURAL) RETURN STD_LOGIC_VECTOR IS
		
	VARIABLE F: STD_LOGIC_VECTOR(0 TO 6);
		
	BEGIN
	
	CASE S IS
		WHEN 0 => F := "0000001";
		WHEN 1 => F := "1001111";
		WHEN 2 => F := "0010010";
		WHEN 3 => F := "0000110";
		WHEN 4 => F := "1001100";
		WHEN 5 => F := "0100100";
		WHEN 6 => F := "0100000";
		WHEN 7 => F := "0001111";
		WHEN 8 => F := "0000000";
		WHEN 9 => F := "0000100";
		WHEN OTHERS => F := "1111110";
	END CASE;
			
		RETURN F;
	END FUNCTION dispSSD;
-------------------------------------------------------------------------------
	FUNCTION rise_edge (SIGNAL CLK: STD_LOGIC) RETURN BOOLEAN IS
	
	BEGIN
	
	RETURN (CLK'EVENT AND CLK='1');
	
	END FUNCTION rise_edge;
-------------------------------------------------------------------------------
	PROCEDURE slow_the_clock (SIGNAL ip_clock, rst: IN STD_LOGIC;
										CONSTANT divider: IN NATURAL;
										SIGNAL op_clock: OUT STD_LOGIC) IS
										
	VARIABLE counter: NATURAL;
	VARIABLE slow_clk: STD_LOGIC := '0';
	
	BEGIN
	
	IF rise_edge(ip_clock) THEN
		counter := counter+1;
		IF (counter = divider) THEN
			counter := 0;
			slow_clk := NOT slow_clk;
		END IF;
	END IF;
	IF rst = '1' THEN counter := 0; END IF;
	
	op_clock <= slow_clk;
	
	END PROCEDURE slow_the_clock;
-------------------------------------------------------------------------------
	PROCEDURE clock_display (SIGNAL clock: IN STD_LOGIC;
										SIGNAL hours_tens, hours_ones,
										minutes_tens, minutes_ones,
										seconds_tens, seconds_ones: INOUT NATURAL RANGE 0 TO 9) IS

	BEGIN
	seconds_ones <= seconds_ones+1;
	IF(seconds_ones >= 9) THEN
		seconds_ones <= 0;
		seconds_tens <= seconds_tens+1;
		IF(seconds_tens >= 5) THEN
			seconds_tens <= 0;
			minutes_ones <= minutes_ones+1;
			IF(minutes_ones >= 9) THEN
				minutes_ones <= 0;
				minutes_tens <= minutes_tens+1;
				IF(minutes_tens >= 5) THEN
					minutes_tens <= 0;
					hours_ones <= hours_ones+1;
					IF(hours_ones >= 9) THEN
						hours_ones <= 0;
						hours_tens <= hours_tens+1;
						IF(hours_tens >= 2 AND hours_ones >= 3) THEN
							hours_tens <= 0;
							hours_ones <= 0;
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;
	
	END clock_display;
-------------------------------------------------------------------------------
END alarm_clock_package;