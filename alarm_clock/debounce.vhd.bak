LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY debounce IS

	PORT(btn, clk: IN STD_LOGIC;
			debounced: OUT STD_LOGIC);
END debounce;

ARCHITECTURE debounce_arch OF debounce IS

--SIGNAL count: INTEGER := 0;
--SIGNAL old_btn: STD_LOGIC := '1';

SIGNAL slow_clk: STD_LOGIC := '0';
CONSTANT divider: INTEGER := 250000; --100Hz

BEGIN

PROCESS(clk, btn)

VARIABLE clk_count: INTEGER := 0;
VARIABLE clk_check: STD_LOGIC := '0';
VARIABLE old_btn: STD_LOGIC := '1';

BEGIN
	IF (btn /= old_btn) THEN
		clk_count := 0;
		old_btn := btn;
	ELSE
		IF(clk'EVENT AND clk='1') THEN
		clk_count := clk_count + 1;
			IF(clk_count = divider AND btn = old_btn) THEN
				debounced <= btn;
			END IF;
		END IF;
	END IF;
END PROCESS;

END debounce_arch;