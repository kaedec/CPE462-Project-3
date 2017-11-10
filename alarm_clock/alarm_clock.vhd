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

CONSTANT divider: NATURAL := 12500; --1Hz (1s)
SIGNAL clock_1Hz: STD_LOGIC := '0';

--Values for the clock time
SIGNAL hours_tens, hours_ones, minutes_tens, minutes_ones,
			seconds_tens, seconds_ones: NATURAL RANGE 0 TO 9 := 0;

--Values for the alarm time
SIGNAL alarm_minutes_ones, alarm_minutes_tens,
			alarm_hours_ones, alarm_hours_tens,
			alarm_seconds_ones, alarm_seconds_tens: NATURAL RANGE 0 TO 9 := 0;

-------------------------------------------------------------------------------
--BEHAVIOR

BEGIN

--Make clock arrays
--clock_time <= (hours_tens, hours_ones, minutes_tens, minutes_ones, seconds_tens, seconds_ones);
--alarm_time <= (alarm_hours_tens, alarm_hours_ones, alarm_minutes_tens, alarm_minutes_ones, 0, 0);

--Debounce the push buttons
alarm_btn: debounce PORT MAP (alarm_set, clock_50MHz, db_alarm_set);
clock_btn: debounce PORT MAP (clock_set, clock_50MHz, db_clock_set);
hour_btn: debounce PORT MAP (hour_set, clock_50MHz, db_hour_set);
min_btn: debounce PORT MAP (minute_set, clock_50MHz, db_minute_set);

--Define clock behavior
PROCESS(clock_50MHz, reset, db_alarm_set, db_clock_set)
VARIABLE counter: NATURAL;

BEGIN
--slow_the_clock(clock_50MHz, reset, divider, clock_1Hz);
IF rise_edge(clock_50MHz) THEN
	counter := counter+1;
	IF (counter = divider) THEN
		counter := 0;
		clock_1Hz <= NOT clock_1Hz;
		IF clock_1Hz='0' THEN
			clock_increment(hours_tens, hours_ones, minutes_tens, minutes_ones, seconds_tens, seconds_ones);
		END IF;
	END IF;
END IF;

hours7 <= dispSSD(hours_tens);
hours6 <= dispSSD(hours_ones);
minutes5 <= dispSSD(minutes_tens);
minutes4 <= dispSSD(minutes_ones);
seconds3 <= dispSSD(seconds_tens);
seconds2 <= dispSSD(seconds_ones);

END PROCESS;

am_pm <= clock_1Hz;

END alarm_clock_arch;