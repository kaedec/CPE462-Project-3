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

CONSTANT divider: NATURAL := 25000000; --1Hz (1s) = 25,000,000
SIGNAL clock_1Hz: STD_LOGIC := '0';
SIGNAL meridiem: STD_LOGIC := '0';
SIGNAL meridiem_alarm: STD_LOGIC := '0';

SIGNAL alarm_enable: STD_LOGIC := '1';

SIGNAL hour_set_change, minute_set_change: STD_LOGIC := '1';

--Values for the clock time
SIGNAL clock_hours_tens, clock_hours_ones, clock_minutes_tens, clock_minutes_ones,
			clock_seconds_tens, clock_seconds_ones: NATURAL RANGE 0 TO 9 := 0;
			
SIGNAL hours_tens, hours_ones, minutes_tens, minutes_ones,
			seconds_tens, seconds_ones: NATURAL RANGE 0 TO 9 := 0;

--Values for the alarm time
SIGNAL alarm_minutes_ones, alarm_minutes_tens,
			alarm_hours_ones, alarm_hours_tens,
			alarm_seconds_ones, alarm_seconds_tens: NATURAL RANGE 0 TO 9 := 0;
			
SIGNAL alarm_minutes_ones_process1, alarm_minutes_tens_process1,
			alarm_hours_ones_process1, alarm_hours_tens_process1,
			alarm_seconds_ones_process1, alarm_seconds_tens_process1: NATURAL RANGE 0 TO 9 := 0;
			
SIGNAL alarm_minutes_ones_process2, alarm_minutes_tens_process2,
			alarm_hours_ones_process2, alarm_hours_tens_process2,
			alarm_seconds_ones_process2, alarm_seconds_tens_process2: NATURAL RANGE 0 TO 9 := 0;

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

--SET_CLOCK: PROCESS(clock_50MHz, db_hour_set, db_minute_set)
--BEGIN
--
--END PROCESS;
--	ELSE
PRODUCE_CLOCK: PROCESS(clock_50MHz, reset, db_clock_set, db_hour_set, db_minute_set)
VARIABLE counter: NATURAL;
--VARIABLE hour_set_change, minute_set_change: STD_LOGIC := '1';

BEGIN

IF rise_edge(clock_50MHz) THEN
	hour_set_change <= db_hour_set;
	minute_set_change <= db_minute_set;
	CASE db_clock_set IS
	WHEN '0' =>
		IF (db_hour_set /= hour_set_change AND db_hour_set = '0') THEN
		alarm_hr_inc(meridiem, clock_hours_tens, clock_hours_ones);
	END IF;
	IF (db_minute_set /= minute_set_change AND db_minute_set = '0') THEN
		alarm_mn_inc(clock_minutes_tens, clock_minutes_ones);
	END IF;
	
	IF reset='1' THEN
		clock_hours_tens <= 1;
		clock_hours_ones <= 2;
		clock_minutes_tens <= 0;
		clock_minutes_ones <= 0;
		clock_seconds_tens <= 0;
		clock_seconds_ones <= 0;
		meridiem <= '0';
	END IF;
	
	WHEN OTHERS =>
	counter := counter+1;
	IF (counter = divider) THEN
		counter := 0;
		clock_1Hz <= NOT clock_1Hz;
		IF clock_1Hz='0' THEN
			clock_increment(meridiem, clock_hours_tens, clock_hours_ones, clock_minutes_tens, clock_minutes_ones, clock_seconds_tens, clock_seconds_ones);
		END IF;
	END IF;
	END CASE;
END IF;

IF reset='1' THEN
	counter := 0;
	clock_hours_tens <= 1;
	clock_hours_ones <= 2;
	clock_minutes_tens <= 0;
	clock_minutes_ones <= 0;
	clock_seconds_tens <= 0;
	clock_seconds_ones <= 0;
	meridiem <= '0';
END IF;

END PROCESS;
						
SET_ALARM: PROCESS(clock_50MHz, db_hour_set, db_minute_set)
BEGIN
	IF (db_alarm_set='0') THEN
		IF fall_edge(db_hour_set) THEN
			alarm_hr_inc(meridiem_alarm, alarm_hours_tens, alarm_hours_ones);
		END IF;
		IF fall_edge(db_minute_set) THEN
			alarm_mn_inc(alarm_minutes_tens, alarm_minutes_ones);
		END IF;
	END IF;
	
	IF reset = '1' THEN
		alarm_hours_tens <= 1;
		alarm_hours_ones <= 2;
		alarm_minutes_tens<= 0;
		alarm_minutes_ones <= 0;
		alarm_seconds_tens <= 0;
		alarm_seconds_ones <= 0;
		meridiem_alarm <= '0';
	END IF;
END PROCESS;

alarm <= test_alarm(alarm_status, meridiem, meridiem_alarm,
							clock_hours_tens, alarm_hours_tens,
							clock_hours_ones, alarm_hours_ones,
							clock_minutes_tens, alarm_minutes_tens,
							clock_minutes_ones, alarm_minutes_ones);
							
hours_tens <= alarm_hours_tens WHEN db_alarm_set = '0' ELSE
					clock_hours_tens;
					
hours_ones <= alarm_hours_ones WHEN db_alarm_set = '0' ELSE
					clock_hours_ones;
					
minutes_tens <= alarm_minutes_tens WHEN db_alarm_set = '0' ELSE
						clock_minutes_tens;
						
minutes_ones <= alarm_minutes_ones WHEN db_alarm_set = '0' ELSE
						clock_minutes_ones;
						
seconds_tens <= alarm_seconds_tens WHEN db_alarm_set = '0' ELSE
						clock_seconds_tens;
						
seconds_ones <= alarm_seconds_ones WHEN db_alarm_set = '0' ELSE
						clock_seconds_ones;

hours7 <= dispSSD(hours_tens);
hours6 <= dispSSD(hours_ones);
minutes5 <= dispSSD(minutes_tens);
minutes4 <= dispSSD(minutes_ones);
seconds3 <= dispSSD(seconds_tens);
seconds2 <= dispSSD(seconds_ones);

am_pm <= meridiem_alarm WHEN db_alarm_set = '0' ELSE
			meridiem;

END alarm_clock_arch;