LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE alarm_clock_package IS
-------------------------------------------------------------------------------
	COMPONENT debounce IS
		PORT(btn, clk: IN STD_LOGIC;
				debounced: OUT STD_LOGIC);
	END COMPONENT;
-------------------------------------------------------------------------------
	COMPONENT clock_display IS
		PORT(clock: IN STD_LOGIC;
			hours_tens, hours_ones,
			minutes_tens, minutes_ones,
			seconds_tens, seconds_ones: IN NATURAL RANGE 0 TO 9);
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
END alarm_clock_package;