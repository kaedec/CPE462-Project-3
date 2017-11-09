LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.alarm_clock_package.ALL;

ENTITY debounce IS

	PORT(btn, clk: IN STD_LOGIC;
			debounced: OUT STD_LOGIC);
END debounce;

ARCHITECTURE debounce_arch OF debounce IS

CONSTANT divider: INTEGER := 250000; --100Hz (10ms)

BEGIN

PROCESS(clk, btn)

VARIABLE clk_count: INTEGER := 0;
VARIABLE old_btn: STD_LOGIC := '1';

BEGIN
	IF (btn /= old_btn) THEN
		clk_count := 0;
		old_btn := btn;
	ELSIF rise_edge(clk) THEN
		clk_count := clk_count + 1;
		IF(clk_count = divider AND btn = old_btn) THEN
			debounced <= btn;
		END IF;
	END IF;
END PROCESS;

END debounce_arch;