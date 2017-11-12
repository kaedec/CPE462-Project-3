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
			am_pm: OUT STD_LOGIC; --LEDG8 AM/PM Indicator
			hours7, hours6: OUT STD_LOGIC_VECTOR(0 TO 6); --SSDs for hours
			minutes5, minutes4: OUT STD_LOGIC_VECTOR(0 TO 6); --SSDs for minutes
			seconds3, seconds2: OUT STD_LOGIC_VECTOR(0 TO 6); --SSDs for seconds
			clock_50MHz: IN STD_LOGIC); --50MHz Clock
END alarm_clock;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--Architecture
ARCHITECTURE alarm_clock_arch OF alarm_clock IS

--DECLARATIONS

--Debounced Push Buttons
SIGNAL db_alarm_set, db_clock_set, db_hour_set, db_minute_set: STD_LOGIC;

--Temp signals for detecting a change in these buttons
SIGNAL hour_set_change, minute_set_change: STD_LOGIC := '1';

--Information for the 50MHz -> 1Hz slow clock conversion
CONSTANT divider: NATURAL := 25000000; --1Hz (1s) = 25,000,000
SIGNAL clock_1Hz: STD_LOGIC := '0';

--Values for the clock time
SIGNAL clock_hours_tens, clock_hours_ones, clock_minutes_tens, clock_minutes_ones,
			clock_seconds_tens, clock_seconds_ones: NATURAL RANGE 0 TO 9 := 0;
SIGNAL meridiem: STD_LOGIC := '0';

--Values for the alarm time
SIGNAL alarm_minutes_ones, alarm_minutes_tens,
			alarm_hours_ones, alarm_hours_tens,
			alarm_seconds_ones, alarm_seconds_tens: NATURAL RANGE 0 TO 9 := 0;
SIGNAL meridiem_alarm: STD_LOGIC := '0';

--Values for the output (select clock or alarm)
SIGNAL hours_tens, hours_ones, minutes_tens, minutes_ones,
			seconds_tens, seconds_ones: NATURAL RANGE 0 TO 9 := 0;
-------------------------------------------------------------------------------
--BEHAVIOR

BEGIN

--Debounce the push buttons
alarm_btn: debounce PORT MAP (alarm_set, clock_50MHz, db_alarm_set);
clock_btn: debounce PORT MAP (clock_set, clock_50MHz, db_clock_set);
hour_btn: debounce PORT MAP (hour_set, clock_50MHz, db_hour_set);
min_btn: debounce PORT MAP (minute_set, clock_50MHz, db_minute_set);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--Define clock behavior
PRODUCE_CLOCK: PROCESS(clock_50MHz, reset)
VARIABLE counter: NATURAL;

BEGIN

IF rise_edge(clock_50MHz) THEN
	hour_set_change <= db_hour_set;
	minute_set_change <= db_minute_set;
	
	
	CASE db_clock_set IS
	--Implement logic for setting the clock
	WHEN '0' =>
		
		IF (db_hour_set /= hour_set_change AND db_hour_set = '0') THEN
			hr_inc(meridiem, clock_hours_tens, clock_hours_ones);
		END IF;
		IF (db_minute_set /= minute_set_change AND db_minute_set = '0') THEN
			mn_inc(clock_minutes_tens, clock_minutes_ones);
		END IF;
-------------------------------------------------------------------------------
	--Implement logic for incrementing the clock every second
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

--Reset logic regardless of state
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

END PROCESS PRODUCE_CLOCK;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--Define alarm behavior
SET_ALARM: PROCESS(clock_50MHz, reset, db_alarm_set, db_hour_set, db_minute_set)
BEGIN

	--Logic for setting the alarm
	IF (db_alarm_set='0') THEN
		IF fall_edge(db_hour_set) THEN
			hr_inc(meridiem_alarm, alarm_hours_tens, alarm_hours_ones);
		END IF;
		IF fall_edge(db_minute_set) THEN
			mn_inc(alarm_minutes_tens, alarm_minutes_ones);
		END IF;
	END IF;
	
	--Reset logic
	IF reset = '1' THEN
		alarm_hours_tens <= 1;
		alarm_hours_ones <= 2;
		alarm_minutes_tens<= 0;
		alarm_minutes_ones <= 0;
		meridiem_alarm <= '0';
	END IF;
END PROCESS SET_ALARM;

--These are always 0
alarm_seconds_tens <= 0;
alarm_seconds_ones <= 0;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--Define alarm LED Output
alarm <= test_alarm(alarm_status, meridiem, meridiem_alarm,
							clock_hours_tens, alarm_hours_tens,
							clock_hours_ones, alarm_hours_ones,
							clock_minutes_tens, alarm_minutes_tens,
							clock_minutes_ones, alarm_minutes_ones);
-------------------------------------------------------------------------------
--Select each output based on whether the clock or alarm time should be displayed
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
-------------------------------------------------------------------------------
--Apply the selection from the above section to the output ports
hours7 <= dispSSD(hours_tens);
hours6 <= dispSSD(hours_ones);
minutes5 <= dispSSD(minutes_tens);
minutes4 <= dispSSD(minutes_ones);
seconds3 <= dispSSD(seconds_tens);
seconds2 <= dispSSD(seconds_ones);

am_pm <= meridiem_alarm WHEN db_alarm_set = '0' ELSE
			meridiem;

END alarm_clock_arch;