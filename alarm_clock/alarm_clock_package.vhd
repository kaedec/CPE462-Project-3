LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE alarm_clock_package IS
-------------------------------------------------------------------------------
	FUNCTION dispSSD (SIGNAL S: NATURAL) RETURN STD_LOGIC_VECTOR;
-------------------------------------------------------------------------------	
	FUNCTION rise_edge (SIGNAL CLK: STD_LOGIC) RETURN BOOLEAN;
-------------------------------------------------------------------------------
END alarm_clock_package;

PACKAGE BODY alarm_clock_package IS
-------------------------------------------------------------------------------
	FUNCTION dispSSD (SIGNAL S: NATURAL) RETURN STD_LOGIC_VECTOR IS
		
	VARIABLE F: STD_LOGIC_VECTOR;
		
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
END alarm_clock_package;