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

CONSTANT divider: NATURAL := 25000000; --1Hz (1s) is 25,000,000
SIGNAL clock_1Hz: STD_LOGIC := '0';
SIGNAL meridiem: STD_LOGIC := '0';
SIGNAL meridiem_alarm: STD_LOGIC := '0';
SIGNAL set_meridiem: STD_LOGIC := '0';

SIGNAL mn_check: BOOLEAN := FALSE;
SIGNAL hr_check: BOOLEAN := FALSE;

--Values for the clock time
SIGNAL clock_hours_tens, clock_hours_ones, clock_minutes_tens, clock_minutes_ones,
			clock_seconds_tens, clock_seconds_ones: NATURAL RANGE 0 TO 9 := 0;
			
SIGNAL hours_tens, hours_ones, minutes_tens, minutes_ones,
			seconds_tens, seconds_ones: NATURAL RANGE 0 TO 9 := 0;

--Values for the alarm time
SIGNAL alarm_minutes_ones, alarm_minutes_tens,
			alarm_hours_ones, alarm_hours_tens,
			alarm_seconds_ones, alarm_seconds_tens: NATURAL RANGE 0 TO 9 := 0;
			
SIGNAL set_clock_hours_ones, set_clock_hours_tens,
			set_clock_minutes_ones, set_clock_minutes_tens,
			set_clock_seconds_ones, set_clock_seconds_tens: NATURAL RANGE 0 TO 9 := 0;
			
SIGNAL gen_clock_hours_ones, gen_clock_hours_tens,
			gen_clock_minutes_ones, gen_clock_minutes_tens,
			gen_clock_seconds_ones, gen_clock_seconds_tens: NATURAL RANGE 0 TO 9 := 0;

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
PRODUCE_CLOCK: PROCESS(clock_50MHz, reset, mn_check, hr_check)
VARIABLE counter: NATURAL;

BEGIN

IF rise_edge(clock_50MHz) THEN
--IF mn_check THEN
--alarm_mn_inc(gen_clock_minutes_tens, gen_clock_minutes_ones);
--mn_check <= FALSE;
--END IF;
--
--IF hr_check THEN
--alarm_hr_inc(meridiem, gen_clock_hours_tens, gen_clock_hours_ones);
--hr_check <= FALSE;
--END IF;
	counter := counter+1;
	IF (counter = divider) THEN
		counter := 0;
		clock_1Hz <= NOT clock_1Hz;
		IF clock_1Hz='0' THEN
			clock_increment(meridiem, gen_clock_hours_tens, gen_clock_hours_ones, gen_clock_minutes_tens, gen_clock_minutes_ones, gen_clock_seconds_tens, gen_clock_seconds_ones);

		END IF;
	END IF;
END IF;



IF RESET='1' THEN
	counter := 0;
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
	END IF;
END PROCESS;

--SET_CLOCK: PROCESS(clock_50MHz, db_hour_set, db_minute_set)
--BEGIN

--hr_check <= '0';
--mn_check <= '0';

--IF(db_clock_set='0') THEN
--	mn_check <= fall_edge(db_minute_set);
--	hr_check <= fall_edge(db_hour_set);
	--IF fall_edge(db_hour_set) THEN
		--alarm_hr_inc(set_meridiem, set_clock_hours_tens, set_clock_hours_ones);
		--hr_check <= '1';
	--END IF;
	--IF fall_edge(db_minute_set) THEN
		--alarm_mn_inc(set_clock_minutes_tens, set_clock_minutes_ones);
		--mn_check <= '1';
	--END IF;
--END IF;

mn_check <= fall_edge(db_minute_set) WHEN db_clock_set='0' ELSE
				FALSE;
hr_check <= fall_edge(db_hour_set) WHEN db_clock_set='0' ELSE
				FALSE;

--IF reset='1' THEN
--	set_clock_hours_tens <= 1;
--	set_clock_hours_ones <= 2;
--	set_clock_minutes_tens <= 0;
--	set_clock_minutes_ones <= 0;
--	set_clock_seconds_tens <= 0;
--	set_clock_seconds_ones <= 0;
--	set_meridiem <= '0';
--END IF;
--END PROCESS;

--clock_hours_ones <= set_clock_hours_ones WHEN set_clock_hours_ones > gen_clock_hours_ones ELSE
--							gen_clock_hours_ones;

hours_tens <= alarm_hours_tens WHEN db_alarm_set = '0' ELSE
					gen_clock_hours_tens;
					
hours_ones <= alarm_hours_ones WHEN db_alarm_set = '0' ELSE
					gen_clock_hours_ones;
					
minutes_tens <= alarm_minutes_tens WHEN db_alarm_set = '0' ELSE
						gen_clock_minutes_tens;
						
minutes_ones <= alarm_minutes_ones WHEN db_alarm_set = '0' ELSE
						gen_clock_minutes_ones;
						
seconds_tens <= alarm_seconds_tens WHEN db_alarm_set = '0' ELSE
						gen_clock_seconds_tens;
						
seconds_ones <= alarm_seconds_ones WHEN db_alarm_set = '0' ELSE
						gen_clock_seconds_ones;

hours7 <= dispSSD(hours_tens);
hours6 <= dispSSD(hours_ones);
minutes5 <= dispSSD(minutes_tens);
minutes4 <= dispSSD(minutes_ones);
seconds3 <= dispSSD(seconds_tens);
seconds2 <= dispSSD(seconds_ones);

am_pm <= meridiem_alarm WHEN db_alarm_set = '0' ELSE
			meridiem;

END alarm_clock_arch;