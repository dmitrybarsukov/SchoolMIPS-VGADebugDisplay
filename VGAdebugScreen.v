`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NSTU
// Engineer: Barsukov D. R.
//////////////////////////////////////////////////////////////////////////////////


module VGAdebugScreen(
    input               clk108mhz,  // VGA clock 108 MHz
    output reg  [4:0]   regAddr,    // Used to request registers value from SchoolMIPS core
    input       [31:0]  regData,    // Register value from SchoolMIPS
    input               reset,      // positive reset
    input       [11:0]  bgColor,    // Background color in format: RRRRGGGGBBBB, MSB first
    input       [11:0]  fgColor,    // Foreground color in format: RRRRGGGGBBBB, MSB first
    output reg  [11:0]  RGBsig,     // Output VGA video signal in format: RRRRGGGGBBBB, MSB first
    output              hsync,      // VGA hsync
    output              vsync       // VGA vsync
);

    wire    [11:0]  pixelLine;          // pixel Y coordinate
    wire    [11:0]  pixelColumn;        // pixel X coordinate
    reg     [11:0]  symbolLine;         // symbol Y coordinate       
    reg     [11:0]  symbolColumn;       // symbol X coordinate

    reg     [7:0]   symbolCode;         // Current symbol code
    reg     [2:0]   pixelX;             // pixel X coordinate within symbol
    reg     [3:0]   pixelY;             // pixel Y coordinate within symbol
    wire            onoff;              // Is pixel on or off
    
    wire    [7:0]   symbolCodeFromConv; // Symbol code from bin2ascii converter
    wire    [7:0]   symbolCodeFromROM;  // Symbol code from displayROM

    reg     [3:0]   tetrad; // 4-byte value to be converted to 0...9, A...F symbol

    VGAsync vgasync
    (
        .clk108mhz(clk108mhz),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .line(pixelLine),
        .column(pixelColumn)
    );

    fontROM font
    (
        .x(pixelX),
        .y(pixelY),
        .symbolCode(symbolCode),
        .onoff(onoff)
    );

    displayROM dispROM
    (
        .symbolLine(symbolLine),
        .symbolColumn(symbolColumn),
        .symbolCode(symbolCodeFromROM)
    );

    Bin2ASCII bin2asciiconv
    (
        .tetrad(tetrad),
        .symbolCode(symbolCodeFromConv)
    );

    localparam REGISTERS_VALUE_POS = 6; // X position of registers values

    always @(pixelLine or pixelColumn or reset)
    begin
        if(!reset)
        begin
            if(pixelLine < 1024 && pixelColumn < 1280) // Current pixel is on the screen
            begin

                symbolColumn    = pixelColumn / 2 / 8;
                symbolLine      = pixelLine / 2 / 16;
                
                if(symbolColumn >= REGISTERS_VALUE_POS && symbolColumn < REGISTERS_VALUE_POS + 8) // Symbol should be read from SchoolMIPS register
                begin
                    regAddr     = symbolLine;
                    tetrad      = regData >> (28 - (symbolColumn - REGISTERS_VALUE_POS) * 4);
                    symbolCode  = symbolCodeFromConv;
                end
                else // Symbol should be read from displayROM
                begin
                    symbolCode  = symbolCodeFromROM;
                end

                pixelX = (pixelColumn / 2) % 8;
                pixelY = (pixelLine / 2) % 16;

                RGBsig = onoff ? fgColor : bgColor;

            end
            else // Current pixel is in blanking time
            begin
                RGBsig = 12'h000;
            end
        end
        else
        begin  // If reset
            RGBsig = 12'h000;
        end
    end
    
endmodule


module Bin2ASCII(
    input       [3:0]   tetrad,
    output reg  [7:0]   symbolCode
);

    always @(*)
    begin
        if(tetrad < 10)
            symbolCode = tetrad + 8'h30;      // 0...9
        else
            symbolCode = tetrad -10 + 8'h41;  // A...F
    end

endmodule


module displayROM(
    input   [11:0]  symbolLine,    // 0...31
    input   [11:0]  symbolColumn,  // 0...79
    output  [7:0]   symbolCode
);

    reg [7:0] dispROM [2560-1:0];

    initial
    begin
        $readmemh("displayROM.hex", dispROM);
    end

    assign symbolCode = dispROM[symbolLine * 80 + symbolColumn];

endmodule


module fontROM(
    input   [7:0]   symbolCode, // ASCII symbol code
    input   [2:0]   x,          // X position of pixel in the symbol
    input   [3:0]   y,          // Y position of pixel in the symbol
    output          onoff       // Is pixel on or off
);
    
    reg [7:0] glyphROM [4096-1:0];

    initial
    begin
        $readmemh("displayfont.hex", glyphROM); 
    end
    
    assign onoff = glyphROM[symbolCode * 16 + y][7 - x];

endmodule
