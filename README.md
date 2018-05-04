This is FPGA module for displaying contents of SchoolMIPS registers on 1280x1024 VGA display


Connections:

clk108mhz:  provide 108 MHz clock here
regAddr:    connect to SchoolMIPS regAddr
regData:    connect to SchoolMIPS regData
reset:      positive reset
bgColor:    12 bit background color in format: 1'bRRRRGGGGBBBB, MSB first
fgColor:    12 bit text       color in format: 1'bRRRRGGGGBBBB, MSB first
RGBsig:     output VGA video signal in format: 1'bRRRRGGGGBBBB, MSB first
hsync,      VGA hsync signal
vsync       VGA vsync signal


example colors:

12'h000 - black
12'hF00 - red
12'hFF0 - yellow
12'h0F0 - green
12'h0FF - blue
12'h00F - deep blue
12'hF0F - pink
12'hFFF - white