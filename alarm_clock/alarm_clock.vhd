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
		  clock_50MHz: IN STD_LOGIC); --50MHz Clock
END alarm_clock;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--Architecture
ARCHITECTURE alarm_clock_arch OF alarm_clock IS

--DECLARATIONS

--Debounced Push Buttons
SIGNAL db_alarm_set, db_clock_set, db_hour_set, db_minute_set: STD_LOGIC;

CONSTANT divider: NATURAL := 25000000; --1Hz (1s)
SIGNAL clock_1Hz: STD_LOGIC;

SIGNAL seconds_ones, seconds_tens,
			minutes_ones, minutes_tens,
			hours_ones, hours_tens: NATURAL := 0;

-------------------------------------------------------------------------------
--BEHAVIOR

BEGIN

--Debounce the push buttons
alarm_btn: debounce PORT MAP (alarm_set, clock_50MHz, db_alarm_set);
clock_btn: debounce PORT MAP (clock_set, clock_50MHz, db_clock_set);
hour_btn: debounce PORT MAP (hour_set, clock_50MHz, db_hour_set);
min_btn: debounce PORT MAP (minute_set, clock_50MHz, db_minute_set);

--Produce a clk of Frequency 1Hz (1s)
slow_the_clock(clock_50MHz, reset, divider, clock_1Hz);



--Define clock display behavior
--THIS INCREASES THE CLOCK OVER TIME

Incrementer: clock_display PORT MAP (clock_1Hz, hours_tens, hours_ones,
													minutes_tens, minutes_ones, seconds_tens, seconds_ones);

hours7 <= dispSSD(hours_tens);
hours6 <= dispSSD(hours_ones);
minutes5 <= dispSSD(minutes_tens);
minutes4 <= dispSSD(minutes_ones);
seconds3 <= dispSSD(seconds_tens);
seconds2 <= dispSSD(seconds_ones);

END alarm_clock_arch;