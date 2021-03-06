`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:Andrés Arroyo Romero
//
// Create Date: 03/24/2017 11:48:12 PM
// Design Name:
// Module Name: Interfaz
// Project Name:RTC
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module Interfaz( //Definicion entradas y salidas
    input wire clk,reset,resetSync,
    input wire instrucciones,ProgramarCrono,ring,
    input wire inicioSecuencia,//Indica si se esta iniciando una secuencia de la transmision de datos
    input wire [7:0] datoRTC,//Dato proveniente del RTC
    input wire [7:0] cursor,
    input wire Escribir,
    output wire  [11:0] rgbO,
    output wire hsync,vsync,
    output wire video_on,

    //Datos Paralelo de entrada
    input wire [7:0] datos0,datos1,datos2,datos3,datos4,datos5,datos6,datos7,datos8,
    datos9,datos10,
    output wire [9:0] pixelx, pixely
    //output reg [3:0] contGuardados
    );

//_____________________________________________________________________
//Instanciaciones
//_____________________________________________________________________

//SincronizadorVGA
//wire [9:0] pixelx, pixely;

SincronizadorVGA SincronizadorVGA_unit(
          .clk(clk),.reset(resetSync),
          .hsync(hsync),.vsync(vsync),.video_on(video_on),
          .pixelx(pixelx),.pixely(pixely)
          );

//_____________________________________________________________________
//Declaracion de constantes
//_____________________________________________________________________

reg [7:0] datoRTC_reg=8'd0;



//Tick antes de refrescar la pantalla
reg tick;//Tick para guardar datos mientras se refresca la pantalla, para que al volver a imprimir los datos esten listos para ser leidos

//Modulo para pasar los Datos del RTC a codigo Ascii
//reg [3:0]  tamContador;//Tamaño del contador de datos guardados
reg [4:0] contGuardados;//Cuenta los datos guardados
reg finalizoContar;//Indica cuando el contador finalizo su cuenta

reg [6:0] dirAsciiDatoU;
reg [6:0] dirAsciiDatoD;
reg [6:0] dirAsciiDatoSigU;//Registro para almacenar la siguiente direccion Ascii de las unidades del dato proveniente del RTC
reg [6:0] dirAsciiDatoSigD;//Registro para almacenar la siguiente direccion Ascii de las decenas del dato proveniente del RTC
reg w, r;//Habilitan el modo escritura o lectura de los registros respectivamente

//Registros con las direcciones de memoria
//Direcciones de los datos de RTC
//Reloj
reg [6:0] SegundosU, minutosU,horasU, fechaU,mesU,anoU,diaSemanaU, numeroSemanaU;
reg [6:0] SegundosD,minutosD,horasD,fechaD,mesD,anoD,diaSemanaD,numeroSemanaD;
//Temporizador
reg [6:0] SegundosUT,minutosUT,horasUT;//Inicio de registros en 0
reg [6:0] SegundosDT,minutosDT,horasDT;//Inicio de registros en 0
//Direcciones Datos extra


//Selector de Registros
wire [10:0] rom_addrAscii;//Almacena la direccion de memoria completa
wire [17:0] rom_addrGraficos;
wire [7:0] font_word; // datos de memoria
wire [2:0] color_addr; //Tres bits porque por ahora se van a manejar 15 colores



//Tamaño de fuentes
wire [1:0] font_size;// Tamaño de fuente
//wire [2:0]  bit_addr;
reg [2:0] f8,f16,f32;


//Mux recorrido columnas Memoria
reg  font_bit ;//Bit que determina si un pixel de la pantalla esta activo o no
wire dp;


//Mux Seleccion memoria graficos o font rom
wire [11:0] datoGraficos;

reg datoMemorias;
wire graficos;

//Color
reg [11:0] color;
reg [11:0] colorMux;

reg zero=0;// Para concatenar 0s

reg [6:0] contadorAlarma;
reg alternarColor=0;
reg [11:0] colorAlarma=12'hf11;
//Cursor ***************


//Salida VGA***********
reg [11:0] rgb;


//*******************************************************************************************
//_____________________________________________________________________
//Cuerpo
//_____________________________________________________________________

//Tick antes de refrescar la pantalla
always @(posedge clk)//Se activa la señal tick cuando la pantalla comienza a refrescarse
if (finalizoContar==1'd0 & pixely>=10'd480) //finalizoContar desactiva la señal cuando ya se guardaron todos los datos
begin
  tick=1;
end
else
begin
  tick=0;
end//Probado


/*
//Asignacion del codigo ascii para los datos
always@ (posedge clk)
 datoRTC_reg<=datoRTC;

always @*
      case(datoRTC_reg)//Le asigna el valor Ascii del dato proveniente del RTC Unidades

             8'd0: dirAsciiDatoSigU = 7'h30;
             8'd1: dirAsciiDatoSigU = 7'h31;
             8'd2: dirAsciiDatoSigU = 7'h32;
             8'd3: dirAsciiDatoSigU = 7'h33;
             8'd4: dirAsciiDatoSigU = 7'h34;
             8'd5: dirAsciiDatoSigU = 7'h35;
             8'd6: dirAsciiDatoSigU = 7'h36;
             8'd7: dirAsciiDatoSigU = 7'h37;
             8'd8: dirAsciiDatoSigU = 7'h38;
             8'd9: dirAsciiDatoSigU = 7'h39;
             8'd10: dirAsciiDatoSigU = 7'h30;
             8'd11: dirAsciiDatoSigU = 7'h31;
             8'd12: dirAsciiDatoSigU = 7'h32;
             8'd13: dirAsciiDatoSigU = 7'h33;
             8'd14: dirAsciiDatoSigU = 7'h34;
             8'd15: dirAsciiDatoSigU = 7'h35;
             8'd16: dirAsciiDatoSigU = 7'h36;
             8'd17: dirAsciiDatoSigU = 7'h37;
             8'd18: dirAsciiDatoSigU = 7'h38;
             8'd19: dirAsciiDatoSigU = 7'h39;
             8'd20: dirAsciiDatoSigU = 7'h30;
             8'd21: dirAsciiDatoSigU = 7'h31;
             8'd22: dirAsciiDatoSigU = 7'h32;
             8'd23: dirAsciiDatoSigU = 7'h33;
             8'd24: dirAsciiDatoSigU = 7'h34;
             8'd25: dirAsciiDatoSigU = 7'h35;
             8'd26: dirAsciiDatoSigU = 7'h36;
             8'd27: dirAsciiDatoSigU = 7'h37;
             8'd28: dirAsciiDatoSigU = 7'h38;
             8'd29: dirAsciiDatoSigU = 7'h39;
             8'd30: dirAsciiDatoSigU = 7'h30;
             8'd31: dirAsciiDatoSigU = 7'h31;
             8'd32: dirAsciiDatoSigU = 7'h32;
             8'd33: dirAsciiDatoSigU = 7'h33;
             8'd34: dirAsciiDatoSigU = 7'h34;
             8'd35: dirAsciiDatoSigU = 7'h35;
             8'd36: dirAsciiDatoSigU = 7'h36;
             8'd37: dirAsciiDatoSigU = 7'h37;
             8'd38: dirAsciiDatoSigU = 7'h38;
             8'd39: dirAsciiDatoSigU = 7'h39;
             8'd40: dirAsciiDatoSigU = 7'h30;
             8'd41: dirAsciiDatoSigU = 7'h31;
             8'd42: dirAsciiDatoSigU = 7'h32;
             8'd43: dirAsciiDatoSigU = 7'h33;
             8'd44: dirAsciiDatoSigU = 7'h34;
             8'd45: dirAsciiDatoSigU = 7'h35;
             8'd46: dirAsciiDatoSigU = 7'h36;
             8'd47: dirAsciiDatoSigU = 7'h37;
             8'd48: dirAsciiDatoSigU = 7'h38;
             8'd49: dirAsciiDatoSigU = 7'h39;
             8'd50: dirAsciiDatoSigU = 7'h30;
             8'd51: dirAsciiDatoSigU = 7'h31;
             8'd52: dirAsciiDatoSigU = 7'h32;
             8'd53: dirAsciiDatoSigU = 7'h33;
             8'd54: dirAsciiDatoSigU = 7'h34;
             8'd55: dirAsciiDatoSigU = 7'h35;
             8'd56: dirAsciiDatoSigU = 7'h36;
             8'd57: dirAsciiDatoSigU = 7'h37;
             8'd58: dirAsciiDatoSigU = 7'h38;
             8'd59: dirAsciiDatoSigU = 7'h39;
             8'd60: dirAsciiDatoSigU = 7'h30;
             default : dirAsciiDatoSigU = 7'hff;
      endcase

//Decenas
always @*
  case(datoRTC_reg)//Le asigna el valor Ascii del dato proveniente del RTC Decenas

          8'd0: dirAsciiDatoSigD = 7'h30;
          8'd1: dirAsciiDatoSigD = 7'h30;
          8'd2: dirAsciiDatoSigD = 7'h30;
          8'd3: dirAsciiDatoSigD = 7'h30;
          8'd4: dirAsciiDatoSigD = 7'h30;
          8'd5: dirAsciiDatoSigD = 7'h30;
          8'd6: dirAsciiDatoSigD = 7'h30;
          8'd7: dirAsciiDatoSigD = 7'h30;
          8'd8: dirAsciiDatoSigD = 7'h30;
          8'd9: dirAsciiDatoSigD = 7'h30;
          8'd10: dirAsciiDatoSigD = 7'h31;
          8'd11: dirAsciiDatoSigD = 7'h31;
          8'd12: dirAsciiDatoSigD = 7'h31;
          8'd13: dirAsciiDatoSigD = 7'h31;
          8'd14: dirAsciiDatoSigD = 7'h31;
          8'd15: dirAsciiDatoSigD = 7'h31;
          8'd16: dirAsciiDatoSigD = 7'h31;
          8'd17: dirAsciiDatoSigD = 7'h31;
          8'd18: dirAsciiDatoSigD = 7'h31;
          8'd19: dirAsciiDatoSigD = 7'h31;
          8'd20: dirAsciiDatoSigD = 7'h32;
          8'd21: dirAsciiDatoSigD = 7'h32;
          8'd22: dirAsciiDatoSigD = 7'h32;
          8'd23: dirAsciiDatoSigD = 7'h32;
          8'd24: dirAsciiDatoSigD = 7'h32;
          8'd25: dirAsciiDatoSigD = 7'h32;
          8'd26: dirAsciiDatoSigD = 7'h32;
          8'd27: dirAsciiDatoSigD = 7'h32;
          8'd28: dirAsciiDatoSigD = 7'h32;
          8'd29: dirAsciiDatoSigD = 7'h32;
          8'd30: dirAsciiDatoSigD = 7'h33;
          8'd31: dirAsciiDatoSigD = 7'h33;
          8'd32: dirAsciiDatoSigD = 7'h33;
          8'd33: dirAsciiDatoSigD = 7'h33;
          8'd34: dirAsciiDatoSigD = 7'h33;
          8'd35: dirAsciiDatoSigD = 7'h33;
          8'd36: dirAsciiDatoSigD = 7'h33;
          8'd37: dirAsciiDatoSigD = 7'h33;
          8'd38: dirAsciiDatoSigD = 7'h33;
          8'd39: dirAsciiDatoSigD = 7'h33;
          8'd40: dirAsciiDatoSigD = 7'h34;
          8'd41: dirAsciiDatoSigD = 7'h34;
          8'd42: dirAsciiDatoSigD = 7'h34;
          8'd43: dirAsciiDatoSigD = 7'h34;
          8'd44: dirAsciiDatoSigD = 7'h34;
          8'd45: dirAsciiDatoSigD = 7'h34;
          8'd46: dirAsciiDatoSigD = 7'h34;
          8'd47: dirAsciiDatoSigD = 7'h34;
          8'd48: dirAsciiDatoSigD = 7'h34;
          8'd49: dirAsciiDatoSigD = 7'h34;
          8'd50: dirAsciiDatoSigD = 7'h35;
          8'd51: dirAsciiDatoSigD = 7'h35;
          8'd52: dirAsciiDatoSigD = 7'h35;
          8'd53: dirAsciiDatoSigD = 7'h35;
          8'd54: dirAsciiDatoSigD = 7'h35;
          8'd55: dirAsciiDatoSigD = 7'h35;
          8'd56: dirAsciiDatoSigD = 7'h35;
          8'd57: dirAsciiDatoSigD = 7'h35;
          8'd58: dirAsciiDatoSigD = 7'h35;
          8'd59: dirAsciiDatoSigD = 7'h35;
          8'd60: dirAsciiDatoSigD = 7'h36;
          default : dirAsciiDatoSigD = 7'hff;
   endcase
*/
/*
always @(posedge clk, posedge reset)// Cada vez que se refresca la pantalla se guarda una secuencia de datos

if (reset) begin
r<=1;//Señal modo lectura
w<= 0;
dirAsciiDatoU <= 7'h00;
dirAsciiDatoD <= 7'h00;

contGuardados<=5'd0;
finalizoContar<=1'd0;
end



else begin

if (tick==1'd1 && )
begin
r<= 0;
w<= 1; //Señal modo escritura
dirAsciiDatoU<=dirAsciiDatoSigU;
dirAsciiDatoD<=dirAsciiDatoSigD;

contGuardados<=(contGuardados+5'd1);

end


else
begin
r<=1;//Señal modo lectura
w<= 0;
dirAsciiDatoU<=dirAsciiDatoU;
dirAsciiDatoU<=dirAsciiDatoU;

if (contGuardados==5'hb)//Para que finalizoContar se active unicamente  cuando esto es cierto
begin
finalizoContar<=1;
contGuardados<=0;
end

else
begin
finalizoContar<=0;
end
end
end
*/



//Guarda los datos decodificados en registros intermedios
always @(posedge clk, posedge reset)
//reloj
if (reset)begin
SegundosU <= 7'h00;
SegundosD<= 7'h00;
minutosU <= 7'h00;
minutosD <= 7'h00;
horasU <= 7'h00;
horasD <= 7'h00;
fechaU <= 7'h00;
fechaD <= 7'h00;
mesU <= 7'h00;
mesD <= 7'h00;
anoU <= 7'h00;
anoD <= 7'h00;
diaSemanaU <= 7'h00;
diaSemanaD <= 7'h00;
numeroSemanaU <= 7'h00;
numeroSemanaD <= 7'h00;
SegundosUT <= 7'h00;
SegundosDT <= 7'h00;
minutosUT <= 7'h00;
minutosDT <= 7'h00;
horasUT <= 7'h00;
horasDT <= 7'h00;

end

else begin

if (tick)begin
SegundosU <= {4'h3,datos0[3:0]};
SegundosD <= {4'h3,datos0[7:4]};

minutosU <= {4'h3,datos1[3:0]};
minutosD <= {4'h3,datos1[7:4]};

horasU <= {4'h3,datos2[3:0]};
horasD <= {4'h3,datos2[7:4]};

fechaU <= {4'h3,datos3[3:0]};
fechaD <= {4'h3,datos3[7:4]};

mesU <= {4'h3,datos4[3:0]};
mesD <= {4'h3,datos4[7:4]};

anoU <= {4'h3,datos5[3:0]};
anoD <= {4'h3,datos5[7:4]};

diaSemanaU <= {4'h3,datos6[3:0]};
diaSemanaD <= {4'h3,datos6[7:4]};

numeroSemanaU <= {4'h3,datos7[3:0]};
numeroSemanaD <= {4'h3,datos7[7:4]};

//Temporizador
SegundosUT <= {4'h3,datos8[3:0]};
SegundosDT <= {4'h3,datos8[7:4]};

minutosUT <= {4'h3,datos9[3:0]};
minutosDT <= {4'h3,datos9[7:4]};

horasUT <= {4'h3,datos10[3:0]};
horasDT <= {4'h3,datos10[7:4]};

end

else begin
SegundosU <= SegundosU;
SegundosD <= SegundosD;
minutosU <= minutosU;
minutosD <= minutosD;
horasU <= horasU;
horasD <= horasD;
fechaU <= fechaU;
fechaD <= fechaD;
mesU <= mesU;
mesD <= mesD;
anoU <= anoU;
anoD <= anoD;
diaSemanaU <= diaSemanaU;
diaSemanaD <= diaSemanaD;
numeroSemanaU <= numeroSemanaU;
numeroSemanaD <= numeroSemanaD;
SegundosUT <= SegundosUT;
SegundosDT <= SegundosDT;
minutosUT <= minutosUT;
minutosDT <= minutosDT;
horasUT <= horasUT;
horasDT <= horasDT;
end

end



//Registros Datos principales


//____________________________________________________________________________________________________
//____________________________________________________________________________________________________
//Sección  Lectura


//Selector de registros
//Impresion de datos

ImpresionDatos ImpresionDatos_unit
    (
    .clk(clk),.pixelx(pixelx),.pixely(pixely),.rom_addr(rom_addrAscii),
    .font_sizeo(font_size),.color_addro(color_addr),
    .SegundosU(SegundosU),.SegundosD(SegundosD),.minutosU(minutosU)
    ,.minutosD(minutosD),.horasU(horasU),.horasD(horasD),.dpo(dp)
    ,.fechaU(fechaU),.mesU(mesU),.anoU(anoU),.diaSemanaU(diaSemanaU),
     .numeroSemanaU(numeroSemanaU),.fechaD(fechaD),.mesD(mesD),.anoD(anoD),.diaSemanaD(diaSemanaD),
     .numeroSemanaD(numeroSemanaD),.memInto(memInt),.graficosO(graficos),.rom_addrGraficos(rom_addrGraficos),
     .SegundosUT(SegundosUT),.minutosUT(minutosUT),.horasUT(horasUT),
     .SegundosDT(SegundosDT),.minutosDT(minutosDT),.horasDT(horasDT),.instrucciones(instrucciones),.cursor(cursor)
     ,.Escribir(Escribir),.ProgramarCrono(ProgramarCrono)
    );




//Memoria Ascii
Font_rom Font_memory_unit
     (
          .dir(rom_addrAscii),
          .clk(clk),
          .data(font_word)
     );




MemoriaGrafica MemoriaGrafica_unit
     (
          .dir(rom_addrGraficos),
          .clk(clk),
          .dato(datoGraficos)
     );



/*
//Mux Seleccion memoria graficos o font rom

     always @*

     if (graficos)begin
     datoMemorias=datoGraficos;
     end

     else begin
     datoMemorias=font_word;
     end
*/






     //Mux columnas
     always @(posedge clk)

     if (dp==1'd1 | graficos == 1'd1 )begin //******Se agrego que si graficos esta activo font_bit siempre esta activo
     if (memInt==1'd1)begin
     font_bit<=1'd1;
     end

     else begin
      //font_bit =font_word [~(bit_addr)]; //Recorre las columnas de los datos extraidos de la memoria

      f8<=pixelx[2:0];
      f16<=pixelx[3:1];
      f32<=pixelx[4:2];

      if (font_size==2'd0)begin
      font_bit <=font_word [~f16];end

      else if (font_size==2'd1)begin
      font_bit <=font_word [~f8];end

      else if (font_size==2'd2)begin
      font_bit <=font_word [~f32];end

      else begin
      font_bit <=font_word [~f8];end


      end
     end



//Rom colores
//Almacena las combinaciones de colores posibles

always @*

case (color_addr) // combinación de colores seleccionados de acuerdo al switch, solo se puede seleccionar un siwtch a la vez
//         r      g    b
//color = 0000  0000  0000

3'd0: color = 12'h032;//Verde
3'd1:  color = 12'h000;//Negro
3'd2: color = 12'hFFE;//Blanco
3'd3: color = 12'h111;
3'd4: color = 12'h222;
3'd5: color = 12'h333;
3'd6: color = 12'h032;
3'd7: color = 12'h120;
default: color = 12'h111;

endcase


/*
//Cambio color alarma
always @(posedge clk)

 if (ring && pixely==10'd525) begin
 if (contadorAlarma==7'd127) begin
alternarColor<=~alternarColor;
contadorAlarma=3'd0;
 end

 else begin
 contadorAlarma<=contadorAlarma+1;
end

if (alternarColor==1) begin
colorAlarma<= 12'h032;
end

else begin
colorAlarma<=color;
end
 end

 else begin
 alternarColor<=alternarColor;

 end
*/


//Mux Salida color



always @*


if (graficos)begin
colorMux=datoGraficos;
end

else if (ring==1  && (pixely >= 10'd473) && (pixely<= 10'd480) ) begin
colorMux= colorAlarma; end //Cambio de color

else begin
colorMux=color;
end


//Salida VGA

always @* //operación se realiza con cada pulso de reloj
    if (font_bit==1'd1 && video_on==1'd1 && dp==1'd1)  //se encienden los LEDs solo si el bit se encuentra en 1 en memoria
        rgb=colorMux;

 else
    rgb = 12'h032;


assign rgbO=rgb;

endmodule
