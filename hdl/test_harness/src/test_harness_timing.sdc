# ##############################################################################

# iCEcube SDC

# Version:            2017.01.27914

# File Generated:     Jul 4 2017 18:03:35

# ##############################################################################

####---- CreateClock list ----2
create_clock  -period 83.33 -name {clk_in} [get_ports {clk_in}] 
create_clock  -period 18.52 -name {clk_pll} [get_ports {clk_out}] 

