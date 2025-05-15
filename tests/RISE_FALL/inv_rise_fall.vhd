------------------------------------------------------------
-- generated automatically by RCG tool
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library std;
use ieee.math_real.all;

entity inv_rise_fall is
  generic(
    DELAY        : time    := 50 ns;
    slewrate_r   : real    := 2.0;
    slewrate_f   : real    := 3.0);
  port(
    i : in  real;
    f : out real);
end entity;

architecture bhv of inv_rise_fall is
  signal internal_f : real := 0.0;
  signal noise : real;
begin

  process
    variable target_f   : real;
  begin
    wait on i;

    if i < 2.5 then
      target_f := 5.0 ;
    else
      target_f := 0.0 ;
    end if;

    -- compute slope
    if trunc(abs(target_f-internal_f)) > 0.5 then
      if target_f > internal_f then
        internal_f <= internal_f + slewrate_r * 1.0 ;
      else
        internal_f <= internal_f - slewrate_f * 1.0 ;
      end if;
    else
      wait for DELAY;
    end if;
  end process;

  noiy_p:process
    variable seed1, seed2 : integer := 345;
    variable r : real;
  begin
    wait for 1 ns;
    uniform(seed1, seed2, r);
    r:=(r-1.0)/10.0;
    noise <= r;
  end process;


    f <= internal_f + noise;



end bhv;
