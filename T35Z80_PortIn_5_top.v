/************************************************************************
*   FILE:  T35Z80_PortIn_5_top.v                                       *
*                                                                       *
*   TFOX, N4TLF September 19, 2022   You are free to use it             *
*       however you like.  No warranty expressed or implied             *
************************************************************************/


module  T35Z80_PortIn_5_top (
//    clockIn,            // 50MHz input from onboard oscillator
    pll0_LOCKED,
    pll0_2MHz,
                    // Next comes all the S100 bus signals
    s100_n_RESET,  // on SBC board reset button (GPIOT_RXP12)
    s100_DI,            // S100 Data In bus
    s100_xrdy,          // xrdy is S100 pin 3, on Mini Front Panel
                        // and Monahan Bus DIsplay Board (BDB)
    s100_rdy,           // second Ready signal, S100 pin
    s100_HOLD,
    //
    S100adr0_15,
    S100adr16_19,
    s100_DO,            // S100 SBC Data Out bus
   
    s100_pDBIN,         // NOTE:  This signal required for SMB or BDB
    s100_pSYNC,         // NOTE:  This signal required for SMB or BDB    
    s100_pSTVAL,        // NOTE:  This signal required for SMB or BDB
    s100_n_pWR,
    s100_sMWRT,         // NOTE:  We don't need to write to anything
    s100_pHLDA,         // Only for the HLDA LED at this point
    s100_PHI,
    s100_CLOCK,         // 2MHz Clock signal to S100 bus    
    s100_sHLTA,
    s100_sINTA,
    s100_n_sWO,
    s100_sMEMR,
    s100_sINP,
    s100_sOUT,
    s100_sM1,
    s100_PHANTOM,       // turn OFF Phantom LED on Front panels
    s100_ADSB,          // turn OFF these (ADSB & SDSB) LEDs on BDB
    s100_CDSB,          // turn OFF these LEDs on BDB
    
                    // Some of the SBC non-S100 output signals
    SBC_LEDs,           // The SBC LEDs for testing
    sw_IOBYTE,          // I/O Byte Switches  NOT USED AS Z80 IOBYTE HERE!
    seg7,
    seg7_dp,
    boardActive,
    F_add_oe,
    F_bus_stat_oe,
    F_out_DO_oe,
    F_out_DI_oe,
    F_bus_ctl_oe);
        
//    input   clockIn;
    input   pll0_LOCKED;
    input   pll0_2MHz;
    input   [7:0] sw_IOBYTE;
    input   s100_n_RESET;
    input   s100_xrdy;
    input   s100_rdy;
    input   s100_HOLD;
    input   [7:0] s100_DI;
    output  [15:0]S100adr0_15;
    output  [3:0] S100adr16_19;
    output  s100_pDBIN;
    output  s100_pSYNC; 
    output  s100_pSTVAL;
    output  s100_n_pWR;
    output  s100_sMWRT;
    output  s100_pHLDA;
    output  [7:0] s100_DO;
    output  s100_PHI;
    output  s100_CLOCK;
    output  s100_sHLTA;
    output  s100_sINTA;
    output  s100_n_sWO;
    output  s100_sMEMR;
    output  s100_sINP;
    output  s100_sOUT;
    output  s100_sM1;
    //
    output  [7:0] SBC_LEDs;
    output  [6:0] seg7;
    output  seg7_dp;
    output  s100_PHANTOM;       // turn OFF phantom light
    output  s100_ADSB;          // turn OFF these LEDs (ADSB & SDSB) on BDB
    output  s100_CDSB;          // turn OFF these LEDs on BDB
    output  boardActive;
    output  F_add_oe;
    output  F_bus_stat_oe;
    output  F_out_DO_oe;
    output  F_out_DI_oe;
    output  F_bus_ctl_oe;
    
///////////////////////////////////////////////////////////////////

    wire    cpuClock;
    wire    z80_n_m1;
    wire    z80_n_mreq;
    wire    z80_n_iorq;
    wire    z80_n_rd;
    wire    z80_n_wr;
    wire    z80_n_rfsh;
    wire    n_halt;
    wire    n_busak;
    wire    z80_n_wait;
    
    wire    [15:0]  cpuAddress;
    wire    [7:0]   cpuDataOut;
    wire    [7:0]   cpuDataIn;
    wire    [7:0]   romOut;
//    wire    [7:0]   inPortCONData;
    wire    [7:0]   out255;
    wire    [7:0]   sw_IOBYTE;
    wire    [7:0]   debugReg;
    wire    n_reset;
    wire    n_resetLatch;
    wire    n_ioWR;         // I/O port WRITE signal
    wire    memRD;        // Memory READ signal
    wire    memWR;
    wire    outFF;
    wire    inPortCON_cs;
    wire    rom_cs;
    wire    n_inta;             // internal INTA signal
    wire    inta;               // TEMPorary POSITIVE INTA 
    wire    mrq_norfsh;         // memory request, NOT refesh
    wire    sWO;                // combined write out
    wire    sOUT;
    wire    sINP;
//    wire    memread;
//    wire    memwrite;
    wire    n_mwr;
    wire    iorq;
    wire    iorqFFclk;
    wire    liorq;              // latched iorq
    wire    psyncstrt;          // start of psync signal
    wire    psyncend;           // end of psync
    wire    endsync;
    wire    busin;              // active high bus in for S100
    wire    pstval;             // ps trobe value
    wire    pdbin;              // pDBIN FF output
    wire    psync;            // pSync
    wire    io_output;          // IO OUTPUT signal
    wire    n_pWR;
    wire    z80_n_HoldIn;
    wire    pHLDA;
    wire    pDBIN;
    wire    statDisable;        // temp?
    wire    ctlDisable;
    
    reg [20:0]  counter;            // 26-bit counter
    wire [6:0]  z80_stat;           // z80 CPU status register
    wire [6:0]  statusout;          // z80 S100 status outputs
    wire [4:0]  controlBus;         // S100 Control signals mux in
    wire [4:0]  controlOut;         // S100 Control Signals Output to bus
    wire [15:0] buildAddress;         // S100 address build location
    
////////////////////////////////////////////////////////////////////////////


assign n_reset = s100_n_RESET;
assign seg7 = 7'b0010010;               // The number "5", Top segment is LSB
assign seg7_dp = !(n_resetLatch & counter[20]); // Tick to show activity

////////////////////////////    TURN ON SBC BUFFERS FOR NOW                        
assign F_add_oe = 0;
assign F_bus_stat_oe = 0;
assign F_out_DO_oe = 0;
assign F_out_DI_oe = 0;
assign F_bus_ctl_oe = 0;

///////////////////////////     Create various S100 and Z80 signals

assign  n_inta = !(!z80_n_m1 & !z80_n_iorq); 
assign  io_output = (!z80_n_wr & !z80_n_iorq);
assign  mrq_norfsh = ((!z80_n_mreq) & z80_n_rfsh); // memory rqst, NOT during refresh
assign  n_mwr = !(mrq_norfsh & z80_n_rd);
assign  sWO = (n_mwr & z80_n_wr);           // combined write out
assign  psyncstrt = !(inta | liorq | mrq_norfsh);   // START_SYNC NOR gate on Waveshare
assign  endsync = !(psyncend);

assign  psync = !(psyncstrt | endsync | !z80_n_rfsh);   // PSYNCRAW NOR gate on Waveshare
assign  busin = (n_inta & z80_n_rd);       // create the BUS IN signal
assign  pstval = !(psync & !cpuClock);   // create the pSTVAL signal
assign  n_pWR = !(endsync & (!z80_n_wr));
assign  sOUT = (!z80_n_wr & !z80_n_iorq);
assign  sINP = (!z80_n_rd & !z80_n_iorq);
assign  memRD = (!z80_n_rd & !z80_n_mreq);
assign  memWR = (!z80_n_wr & !z80_n_mreq);

assign z80_stat[0] = !n_halt;           // inverted z80 !HLTA
assign z80_stat[1] = sOUT;              // sOUT signal
assign z80_stat[2] = sINP;              // sIN signal
assign z80_stat[3] = memRD;             // sMEMR signal
assign z80_stat[4] = sWO;               // create sWO- signal
assign z80_stat[5] = !z80_n_m1;             // create the sM1 signal
assign z80_stat[6] = !n_inta;           // create sINTA signal

assign  controlBus[0] = psync;          // Active High, start of new bus cycle
assign  controlBus[1] = pstval;         // Active LOW, Indicates stable address & status
assign  controlBus[2] = pDBIN;          // Active HIGH, read strobe, slave can input data
assign  controlBus[3] = n_pWR;            // Active LOW, generalized write strobe to slaves
assign  controlBus[4] = pHLDA;          // Active HIGH, Perm Master relinquishing control


//////////////////////////////////////  FIXED S100 SIGNALS HERE /////////////////////
// s100_pDBIN created by read strobe FF below
assign s100_pDBIN = !pDBIN;
assign z80_n_wait = s100_xrdy & s100_rdy;      // Z80 Wait = low to wait
assign s100_pSYNC = psync;
assign s100_pSTVAL = pstval;
assign s100_n_pWR = n_pWR;
assign s100_PHI = cpuClock;
assign s100_CLOCK = pll0_2MHz;             
assign s100_sMWRT = !(n_pWR | io_output);
assign s100_pHLDA = !n_busak;
assign buildAddress[7:0] = cpuAddress [7:0];
//assign S100adr0_15 = buildAddress[15:0];
assign s100_DO = cpuDataOut;         // S100 Data OUT bus signals

//////////////////////////////////////////////////////////////////////////////////////
//      Status Output signals, per IEEE-696.  These signals are latched by pSTVAL   //
//          based on John Monahan's Waveshare design.                               //
//          Status signals are prefixed with an "s"                                 //
//////////////////////////////////////////////////////////////////////////////////////
assign  s100_sHLTA = statusout[0];      //!n_halt;           //statusout[0];
assign  s100_sOUT =  statusout[1];      //sOUT;              //statusout[1];
assign  s100_sINP =  statusout[2];      //sINP;              //statusout[2];
assign  s100_sMEMR = statusout[3];      //memRD;           //statusout[3];
assign  s100_n_sWO = statusout[4];      //sWO;               //statusout[4];
assign  s100_sM1 =   statusout[5];      //!z80_n_m1;             //statusout[5];
assign  s100_sINTA = statusout[6];      //!n_inta;           //statusout[6];

//////////////////////////////////////////////////////////////////////////////////////
//  Control Output signals, per IEEE-696.These signals cannot be tristated based    //
//  on John Monahan's Waveshare design.  Efinix does not have tri-state             //
//  outputs internally, so these outputs are set high instead.... for now           //
//  These signals are prefixed with a "p"                                           //
//////////////////////////////////////////////////////////////////////////////////////
//assign  s100_pSYNC = controlOut[0];
//assign  s100_pSTVAL = cntrolOut[1];
//assign  s100_pDBIN = controlOut[2];
//assign  s100_n_pWR = controlOut[3];
//assign  s100_pHLDA = controlOut[4];

assign s100_PHANTOM = 0;                        // turn OFF the Phantom LED for now
assign s100_ADSB = !statDisable;                // Address and Status Disable
assign s100_CDSB = !ctlDisable;                 // Control Signals Disabe


//////////////////////////////////////  MISC TESTING/DEBUG STUFF
assign boardActive = !pll0_LOCKED;   // LED is LOW to turn ON

//////////////////////////////////////////////////////////////////////////////
//      Debug Register.  These are displayed when IOBYTE switches 5 & 4     //
//          are set to 10 (OFF ON)                                          //
//////////////////////////////////////////////////////////////////////////////
assign debugReg[0] = s100_pSTVAL;
assign debugReg[1] = busin;
assign debugReg[2] = pstval;
assign debugReg[3] = pDBIN;            
assign debugReg[4] = s100_pDBIN;
assign debugReg[5] = s100_sMEMR;
assign debugReg[6] = s100_sINP;
assign debugReg[7] = s100_sOUT;

//////////////////////////////////////////////////////////////////////////
always @(posedge pll0_2MHz)
    begin
        if(n_reset == 0) begin   // if reset set low...
            counter <= 21'b0;                   // reset counter to 0
        end                                 // end of resetting everything
        else
            counter <= counter + 1;         // increment counter
    end
    

////////////////////////////////////////////////////////////////////////////
///////////     Z80 microcomputer module       (Z80 top module)         ////
////////////////////////////////////////////////////////////////////////////
    
microcomputer(
		.n_reset    (n_reset),              // INPUT  LOW to reset
		.clk        (cpuClock),
		
		.n_wr       (z80_n_wr),
		.n_rd       (z80_n_rd),
		.n_mreq     (z80_n_mreq),
		.n_iorq     (z80_n_iorq),
		.n_wait		(z80_n_wait),
        .n_int      (1'b1),
		.n_nmi      (1'b1),
        .n_busrq    (z80_n_HoldIn),
        .n_m1       (z80_n_m1),
        .n_rfsh     (z80_n_rfsh),
        .n_halt     (n_halt),
		.n_busak    (n_busak),
    
		.address    (cpuAddress),
		.dataOut    (cpuDataOut),
		.dataIn     (cpuDataIn)	
		);

/************************************************************************************
*   Memory decoder                                                                  *
************************************************************************************/     
memAdrDecoder  mem_cs(
//   .clock         (cpuClock),
    .address        (buildAddress[15:0]),        // use only Z80 A0-A15 for now
//  .memwrite       (n_memWR),
    .n_memread     (!memRD),
    .rom_cs         (rom_cs)
//    output          ram_cs,
     );

/************************************************************************************
*   Boot ROM for Z80 CPU                                                            *
************************************************************************************/     
rom   #(.ADDR_WIDTH(5),
	.RAM_INIT_FILE("rom.inithex"))
    R1 (
    .address    (buildAddress[4:0]),
	.clock      (cpuClock),
	.data       (romOut[7:0])
);


/************************************************************************************
    IO Ports Decoder.                                                               *
************************************************************************************/
portDecoder ports_cs(
//  .clock          (cpuClock),
    .address        (buildAddress[7:0]),
    .iowrite        (sOUT),     
    .ioread         (sINP),
    .outPortFF_cs   (outFF),
    .inPortCon_cs   (inPortCON_cs)
    );
  
/************************************************************************************
*   Z80 CPU status bits latch.  Output feeds the S100 status bit (sXXXX)            *
************************************************************************************/
n_bitLatch      #(7)
      s100stat(
     .load      (pstval),     //TEMP 11/15
     .clock     (!cpuClock),        //(!s100_pSTVAL),
//     .clr       (1'b0),
     .inData    (z80_stat),
     //
     .regOut    (statusout)
     );

 /************************************************************************************
*   S100 Address 0-15 Latch.     Latches address bus for S100 timing                *
************************************************************************************/

n_bitReg        #(16)
      s100adr(
     .load      (pstval),
     .clock     (!cpuClock),
     .clr       (1'b0),
     .inData    (buildAddress),
     //
     .regOut    (S100adr0_15)
     );

/************************************************************************************
*   S100 Address 16-19 Latch.     Latches address bus A16-A19 for S100 timing       *
************************************************************************************/

n_bitReg        #(4)
      s100adr16_19(
     .load      (pstval),
     .clock     (!cpuClock),
     .clr       (1'b0),
     .inData    (4'b0),
     //
     .regOut    (S100adr16_19)
     );

/************************************************************************************
*   S100 High Address MUX.  Z80 sends I/O Data OUT on A8-A15.  This disables that   *
************************************************************************************/

cpuHAdrMux  HighAdrMux(
    .cpuHighAdr     (cpuAddress[15:8]),
    .sOUT           (sOUT),
    .sINP           (sINP),   
    .HighAdr        (buildAddress[15:8])        
    );

/************************************************************************************
*   S100 Control Bus Signals MUX.  Sets Control bus to Z80 signals or all high      *
************************************************************************************/

ctlBusMux  CtlBusMux(
    .controlin      (controlBus),
    .select         (!n_resetLatch),  
    .controlout     (controlOut)        
    );
     
/************************************************************************************
*   S100 output Port 255 (0xFF) to Front Panel LEDs                                 *
************************************************************************************/
n_bitReg    outPortFF(
 //    #(parameter N = 8)(
     .load      (outFF),
     .clock     (cpuClock),
     .clr       (!n_reset),
     .inData    (cpuDataOut),
     .regOut    (out255)
    );
    
    
/************************************************************************************
*   CPU Data INPUT Multiplexer      Note: Efinix FPGAs do NOT have tristate ability *
************************************************************************************/
cpuDIMux    cpuInMux (
    .romData        (romOut[7:0]),
    .s100DataIn     (s100_DI[7:0]),
     //    .ramData  (ramOut[7:0]),
    .rom_cs         (rom_cs),
    .inPortcon_cs   (inPortCON_cs),
     //    .ram_cs,   
     .outData   (cpuDataIn[7:0])
    );
 
/*************************************************************************************
*   onboard LEDs INPUT Multiplexer.  This allows quick troubleshooting               *
*************************************************************************************/

LedBarMux       lmux(
    .cpuDO      (cpuDataOut [7:0]),
    .cpuDI      (cpuDataIn [7:0]),
    .portFFDO   (out255[7:0]),
    .debugreg   (debugReg[7:0]),
    .sw         (sw_IOBYTE[5:4]),
     //    .ram_cs,   
     .LEDoutData   (SBC_LEDs)
    );

/*********************************************************************************
*   IORQ Latch FF                                                                *
*********************************************************************************/

dff     iorqlatch(
        .clk        (cpuClock),
        .pst_n      (1'b1),
        .clr_n      (!z80_n_iorq),     
        .din        (!z80_n_iorq),
        .q          (liorq)
        );
/********************************************************************************
*   pSYNC End latch FF                                                          *
********************************************************************************/        
dff     endpsync(
        .clk        (cpuClock),
        .pst_n      (!psyncstrt),
        .clr_n      (1'b1),     
        .din        (psyncstrt),
        .q          (psyncend)
        );

/********************************************************************************
*   Read Strobe latch FF    Output creates/latches pDBIN signal                 *
********************************************************************************/
dff2     readstrobe(
        .clk        (!pstval),
//        .pst_n      (1'b1),
        .clr_n      (busin),     
        .din        (busin),
        .q          (pDBIN)
        );

/********************************************************************************
*   RESET Latch FF      Output drived Active LED and Control Out mux            *                                                          *
********************************************************************************/        
dff     resetLatch(
        .clk        (cpuClock),
        .pst_n      (1'b1),
        .clr_n      (1'b1),     
        .din        (1'b1),
        .q          (n_resetLatch)
        );

/********************************************************************************
*   S100 HOLD IN (busreq) Latch FF  Driven from S100 HOLD pin                   *
********************************************************************************/        
dff     holdInLatch(
        .clk        (cpuClock),
        .pst_n      (1'b1),
        .clr_n      (1'b1),     
        .din        (s100_HOLD),
        .q          (z80_n_HoldIn)
        );

/********************************************************************************
*   S100 HLDAout (busak) Latch FF  Outputs HLDA to disable Address and Status   *
********************************************************************************/        
dff     HLDAoutLatch(
        .clk        (!cpuClock),
        .pst_n      (1'b1),
        .clr_n      (!n_busak),     
        .din        (!n_busak),
        .q          (statDisable)
        );

/********************************************************************************
*   S100 HOLD IN (busreq) Latch FF  Driven from S100 HOLD pin                   *
********************************************************************************/        
dff     ctlDisableLatch(
        .clk        (cpuClock),
        .pst_n      (1'b1),
        .clr_n      (1'b1),     
        .din        (!(s100_HOLD | !statDisable)),
        .q          (ctlDisable)
        );


/********************************************************************************
*   CPU Clock input Mux.  Selects one of four clock frequencies                 *
********************************************************************************/
ClockMux    ClkMux(
    .MHz2       (pll0_2MHz),
    .MHz1       (counter[0]),
    .KHz31      (counter[5]),
    .Hz250      (counter[12]),
    .sw         (sw_IOBYTE[7:6]), 
    .cpuclk     (cpuClock)
    );

 
endmodule   
    
