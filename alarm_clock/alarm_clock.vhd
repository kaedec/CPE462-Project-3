LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.alarm_clock_package.ALL;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--Entity Declaration
ENTITY alarm_clock IS

	PORT(alarm_set, clock_set, hour_set, minute_set: IN STD_LOGIC; --Push buttons
		  alarm_status, reset: IN STD_LOGIC; -- Misc inputs
		  alarm: OUT STD_LOGIC; --LEDR0 Alarm Alert
		  am_pm: OUT STD_LOGIC; --LEDG8 AM/PM Indicator (Hour 00-11 = AM/LOW; Hour 12-23 = PM/HIGH);
		  hours7, hours6: OUT STD_LOGIC_VECTOR(0 TO 6); --SSD for hours
		  minutes5, minutes4: OUT STD_LOGIC_VECTOR(0 TO 6); --SSD for minutes
		  seconds3, seconds2: OUT STD_LOGIC_VECTOR(0 TO 6); --SSD for seconds
		  clock_50MHz: STD_LOGIC); --50MHz Clock
END alarm_clock;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--Architecture
ARCHITECTURE alarm_clock_arch OF alarm_clock IS

--DECLARATIONS

--Debounced Push Buttons
SIGNAL db_alarm_set, db_clock_set, db_hour_set, db_minute_set: STD_LOGIC;

-------------------------------------------------------------------------------
--Component Declarations

COMPONENT debounce IS
	PORT(btn, clk: IN STD_LOGIC;
			debounced: OUT STD_LOGIC);
END COMPONENT;
-------------------------------------------------------------------------------
--BEHAVIOR

BEGIN

--Debounce the push buttons
alarm_btn: debounce PORT MAP (alarm_set, clock_50MHz, db_alarm_set);
clock_btn: debounce PORT MAP (clock_set, clock_50MHz, db_clock_set);
hour_btn: debounce PORT MAP (hour_set, clock_50MHz, db_hour_set);
min_btn: debounce PORT MAP (minute_set, clock_50MHz, db_minute_set);


--hours7 <= dispSSD(a);
--hours6 <= dispSSD(b);
--minutes5 <= dispSSD(c);
--minutes4 <= dispSSD(d);
--seconds3 <= dispSSD(e);
--seconds2 <= dispSSD(f);

END alarm_clock_arch;