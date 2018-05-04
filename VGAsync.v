`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NSTU
// Engineer: Barsukov D. R.
//////////////////////////////////////////////////////////////////////////////////

module VGAsync(
    input               clk108mhz,  // VGA clock
    input               reset,      // positive reset
    output reg          hsync,      // hsync output
    output reg          vsync,      // vsync output
    output reg  [11:0]  line,       // current line number [Y]
    output reg  [11:0]  column      // current column number [X]
);

    always @(posedge clk108mhz)
    begin
        if(!reset)
        begin
            column = column + 1;
            
            if(column == 1688)
            begin
                column = 0;
                line = line + 1;
                
                if(line == 1066)
                    line = 0;
                
                if(line >= 1025 && line < 1028)
                    vsync = 1'b0;
                else
                    vsync = 1'b1;                
            end
            
            if(column >= 1328 && column < 1440)
                hsync = 1'b0;
            else
                hsync = 1'b1;                
        end
        else // If reset
        begin
            hsync = 1'b1;
            vsync = 1'b1;
        end
    end
    
endmodule
