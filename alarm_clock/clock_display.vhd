LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.alarm_clock_package.ALL;

ENTITY clock_display IS

	PORT(clock: IN STD_LOGIC;
			hours_tens, hours_ones,
			minutes_tens, minutes_ones,
			seconds_tens, seconds_ones: INOUT NATURAL RANGE 0 TO 9);
END clock_display;

ARCHITECTURE clock_display_arch OF clock_display IS

BEGIN

PROCESS(clock)
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
END PROCESS;


END clock_display_arch;