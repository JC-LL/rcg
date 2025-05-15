------------------------------------------------------------
-- generated automatically by RCG tool
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library std;

entity test_inv_tb is
end entity;

architecture bhv of test_inv_tb is

  constant HALF_PERIOD : time       := 50 ns;
  signal clk           : std_logic  := '0';
  signal reset_n       : std_logic  := '0';


  signal i1 : real := 0.0;
  signal f : real;

  type array_of_real is array(0 to 1) of real;
  signal stimuli : array_of_real := (others => 0.0);



begin
  reset_n <= '0','1' after 13 ns;

  clk     <= not(clk) after HALF_PERIOD;
  ----------------------------------------
  -- design under test
  ----------------------------------------
  dut: entity work.inv_rise_fall
    port map(
      i => i1,
      f => f);
  ----------------------------------------
  -- stimuli generation
  ----------------------------------------
  stim_p: process
  begin
    report("waiting for reset");
    wait until reset_n='1';
    report("starting vector sequence");
    wait until rising_edge(clk);
    stimuli <= (real(5.0),real(5.0));
    wait until rising_edge(clk);
    stimuli <= (real(0.0),real(5.0));
    wait until rising_edge(clk);
    stimuli <= (real(5.0),real(5.0));
    for i in 0 to 20 loop
      wait until rising_edge(clk);
    end loop;
    report "end of simulation";
    std.env.finish;
  end process;

  apply_progressive: process
    variable target : real;
    variable seed1, seed2 : integer := 123;
    variable r : real;
  begin
    wait for 0.1 ns;
    target := (stimuli(0));
    while real(abs(i1-target)) > 0.1 loop
      if target > i1 then
        i1 <= i1 + 0.1;
      else
        i1 <= i1 - 0.1;
      end if;
      wait for 0.1 ns;
    end loop;
    -- ALWAYS add noise to force gates to always react 
    uniform(seed1, seed2, r);
    r:=(r-1.0)/10.0;
    i1 <= i1 + r;
  end process;
end bhv;
