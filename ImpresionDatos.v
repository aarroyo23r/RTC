`timescale 1ns / 1ps

module ImpresionDatos
    (
    input wire clk,
    input wire [6:0] SegundosU,SegundosD,minutosU,minutosD,horasU,horasD,
    input wire [9:0] pixelx, //posición pixel x actual
    input wire [9:0] pixely,//posición pixel y actual
    output wire [10:0] rom_addr,//Direccion en la memoria del dato
    output reg [1:0] font_size,// Tamaño de fuente
    output reg [3:0] color_addr, //Tres bits porque por ahora se van a manejar 15 colores
    output reg dp //Dice si va a haber un dato en pantalla
 );


//Parametros de posiciones en pantalla
//reloj



//Segundos
//Limites en el eje x
localparam IsegundosD=10'd007;
localparam DsegundosD=10'd014;
localparam IsegundosU=10'd015;
localparam DsegundosU=10'd022;
//Limites en el eje y
localparam ARsegundos=10'd0; //Solo 2 porque siempre van a estar a la par
localparam ABsegundos=10'd15;



//Minutos
//Limites en el eje x
localparam IminutosD=10'd007;
localparam DminutosD=10'd014;
localparam IminutosU=10'd015;
localparam DminutosU=10'd022;
//Limites en el eje y
localparam ARminutos=10'd16; //Solo 2 porque siempre van a estar a la par
localparam ABminutos=10'd31;

//horas
//Limites en el eje x
localparam IhorasD=10'd300;
localparam DhorasD=10'd307;
localparam IhorasU=10'd310;
localparam DhorasU=10'd317;
//Limites en el eje y
localparam ARhoras=10'd3; //Solo 2 porque siempre van a estar a la par
localparam ABhoras=10'd19;




 //variables internas de conexión

 reg [6:0] char_addr; //  bits mas significativos de dirreción de memoria, del caracter a imprimir
 wire [3:0] row_addr; //Cambio entre las filas de la memoria, bits menos significativos de pixel y,bit menos significativos de memoria




//body
assign row_addr= pixely[3:0]; //4 bits menos significatvos de y, para variar de filas en la memoria

always @(posedge clk)//Se ejecuta cuando hay un cambio en pixel x o pixel y



//Impresion

 //Para el segundo mozaico x=7-14  y=0-15
   //Segundos
    if ((pixelx >= IsegundosD) && (pixelx<=DsegundosD) && (pixely >= ARsegundos) & (pixely<=ABsegundos))begin
        char_addr = SegundosD; //direccion de lo que se va a imprimir
        color_addr=4'd2;// Color de lo que se va a imprimir
        font_size=2'd1;//Tamaño de fuente
        dp=1'b1; end

    else if ((pixelx >= IsegundosU) && (pixelx<=DsegundosU) && (pixely >= ARsegundos) && (pixely<=ABsegundos))begin
        char_addr = SegundosU; //direccion de lo que se va a imprimir
        color_addr=4'd2;// Color de lo que se va a imprimir
        font_size=1;
        dp=1'b1;end//Tamaño de fuente

//Minutos
  else if ((pixelx >= IminutosD) && (pixelx<=DminutosD) && (pixely >= ARminutos) && (pixely<=ABminutos))begin
      char_addr = minutosD; //direccion de lo que se va a imprimir
      color_addr=4'd2;// Color de lo que se va a imprimir
      font_size=2'd1;
      dp=1'b1;end//Tamaño de fuente

  else if ((pixelx >= IminutosU) && (pixelx<=DminutosU) && (pixely >= ARminutos) && (pixely<=ABminutos))begin
      char_addr = minutosU; //direccion de lo que se va a imprimir
      color_addr=4'd2;// Color de lo que se va a imprimir
      font_size=2'd1;
      dp=1'b1;end//Tamaño de fuente
/*
//Horas
else if ((pixelx >= IhorasD) && (pixelx<=DhorasD) && (pixely >= ARhoras) && (pixely<=ABhoras))begin
    char_addr = horasD; //direccion de lo que se va a imprimir
    color_addr=4'd2;// Color de lo que se va a imprimir
    font_size=2'd1; end//Tamaño de fuente

else if ((pixelx >= IhorasU) && (pixelx<=DhorasU) && (pixely >= ARhoras) && (pixely<=ABhoras))begin
    char_addr = horasU;//direccion de lo que se va a imprimir
    color_addr=4'd2;// Color de lo que se va a imprimir
    font_size=2'd1; end//Tamaño de fuente
*/

 else //Si no se cumple ninguna de estas impresiones se pone la pantalla en negro
 begin
 char_addr = 7'd0;
 dp=1'b0;end

assign rom_addr ={char_addr, row_addr}; //concatena direcciones de registros y filas


endmodule
