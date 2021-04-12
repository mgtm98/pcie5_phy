// TS1 ordered set
// TS1 consists of 16 symbols
// 
//        +------------+-------------------------------------+
//        |Symbol 0    |Gen1/2 COM K28.5  OR  Gen3 0x1E      |
//        +------------+-------------------------------------+
//        |Symbol 1    |Link#                                |
//        +------------+-------------------------------------+
//        |Symbol 2    |Lane#                                |
//        +------------+-------------------------------------+
//        |Symbol 3    |N_FTS                                |
//        +------------+-------------------------------------+
//        |Symbol 4    |Rate ID                              |
//        +------------+-------------------------------------+
//        |Symbol 5    |Train Ctl                            |
//        +------------+-------------------------------------+
//        |Symbol 6-9  |Equalization Control                 |
//        +------------+-------------------------------------+
//        |Symbol 10-13|TS1 ID = 0x4A                        |
//        +------------+-------------------------------------+
//        |Symbol 14-15|TS1 ID = 0x4A or DC Balance Symbols  |
//        +------------+-------------------------------------+
//
// Symbol0: Gen1/2 COM Character used to acquire symbol lock, Gen3 ID for TS1 = 0x1E

// Symbol1: Contains PAD in polling state, assigned a number in other states. Ranges are:
//            - Ports that doesn't support Gen3: 0-255 or PAD
//            - Downstream ports that support Gen3: 0-31 or PAD
//            - Upstream ports that support Gen3: 0-255 or PAD
//
// Symbol2: Contains PAD in polling state, assigned a number in other states. Ranges are 0-31 or PAD
//
// Symbol3: number of FTS needed by the reciver in order to achieve L0 state when existing from L0s. Ranges are 0-255
// NOTE: if extended synch bit is set then 4096 FTS must be sent
//
// Symbol4: Data Rate ID
//            - Bit0: Reserved TODO: What value ?!
//            - Bit1: Gen1 support (must be set to 1) 
//            - Bit2: Gen2 support (bit 1 must be set if Gen2 is supported)
//            - Bit3: Gen3 support (bit 1-2 must be set if Gen3 is supported)
//            - Bit4: Reserved TODO: Gen4 ?!  TOBE: for Gen4
//            - Bit5: Reserved TODO: Gen5 ?!  TOBE: for Gen5
//            - Bit6: Autonomus Change/Selectable De-emphasis
//            - Bit7: Speed change
//
// Symbol5: Equalization Control: Training Control
//            - Bit0: Hot Reset
//            - Bit1: Disable Link
//            - Bit2: Loopback
//            - Bit3: Disable Scrambling (Gen2 only, Reserved for Gen3 TODO: Value ?!)
//            - Bit4: Compliance Receive (optional for Gen1, required for other generations)
//            - Bit7:5: Reserved, set to 0
//
// Symbol6: Equalization Control:
//            - For Gen1/2:
//              + TS1 ID 0x4A encoded as D10.2
//              + EQ TS1 encoded as:
//                * Bit 0:2: Reciver preset hint
//                * Bit 3:6: Transimitter preset hint
//                * Bit 7: set to 1b
//            - For Gen3:
//              + Bit 0:1 Equalization control
//              + Bit2: Reset EIEOS Interval Count
//              + Bit3:6: Transimitter Preset
//              + Bit7: use preset
//
// Symbol7: Equalization Control:
//            - For Gen1/2: TS1 ID 0x4A encoded as D10.2      
//            - For Gen3: 
//              + Bit0:5: FS(Full Swing value) when EC field in symbol6 is set
//              + Bit6:7: Reserved TODO: Value ?!
//
// Symbol8: Equalization Control:
//            - For Gen1/2: TS1 ID 0x4A encoded as D10.2      
//            - For Gen3: 
//              + Bit0:5: LF(Low Frequency value) when EC field in symbol6 is set
//              + Bit6:7: Reserved TODO: Value ?!
//
// Symbol9: Equalization Control:
//            - For Gen1/2: TS1 ID 0x4A encoded as D10.2      
//            - For Gen3: 
//              + Bit0:5: Post Cursor coefficient
//              + Bit6: Reject coefficient values
//              + Bit7: Parity for all bits in symbols 6-7-8-9Bits0:6
//
// Symbol10:13: 
//            - For Gen1/2: TS1 ID 0x4A encoded as D10.2      
//            - For Gen3: Ts1 ID 0x4A
//
// Symbol14:15: 
//            - For Gen1/2: TS1 ID 0x4A encoded as D10.2      
//            - For Gen3: Ts1 ID 0x4A, OR DC Blance Symbol
// --------------------------------------------------------------------------------------------------------
// TS2 ordered set
// TS2 consists of 16 symbols
// 
//        +------------+-------------------------------------+
//        |Symbol 0    |Gen1/2 COM K28.5  OR  Gen3 0x2D      |
//        +------------+-------------------------------------+
//        |Symbol 1    |Link#                                |
//        +------------+-------------------------------------+
//        |Symbol 2    |Lane#                                |
//        +------------+-------------------------------------+
//        |Symbol 3    |N_FTS                                |
//        +------------+-------------------------------------+
//        |Symbol 4    |Rate ID                              |
//        +------------+-------------------------------------+
//        |Symbol 5    |Train Ctl                            |
//        +------------+-------------------------------------+
//        |Symbol 6    |Equalization Control                 |
//        +------------+-------------------------------------+
//        |Symbol 7-13 |TS2 ID = 0x45                        |
//        +------------+-------------------------------------+
//        |Symbol 14-15|TS2 ID = 0x45 or DC Balance Symbols  |
//        +------------+-------------------------------------+
//
// Symbol0: Gen1/2 COM Character used to acquire symbol lock, Gen3 ID for TS2 = 0x2D

// Symbol1: Contains PAD in polling state, assigned a number in other states. Ranges are:
//            - Ports that doesn't support Gen3: 0-255 or PAD
//            - Downstream ports that support Gen3: 0-31 or PAD
//            - Upstream ports that support Gen3: 0-255 or PAD
//
// Symbol2: Contains PAD in polling state, assigned a number in other states. Ranges are 0-31 or PAD
//
// Symbol3: number of FTS needed by the reciver in order to achieve L0 state when existing from L0s. Ranges are 0-255
// NOTE: if extended synch bit is set then 4096 FTS must be sent
//
// Symbol4: Data Rate ID
//            - Bit0: Reserved TODO: What value ?!
//            - Bit1: Gen1 support (must be set to 1) 
//            - Bit2: Gen2 support (bit 1 must be set if Gen2 is supported)
//            - Bit3: Gen3 support (bit 1-2 must be set if Gen3 is supported)
//            - Bit4: Reserved TODO: Gen4 ?!
//            - Bit5: Reserved TODO: Gen5 ?!
//            - Bit6: Autonomus Change/Selectable De-emphasis
//            - Bit7: Speed change
//
// Symbol5: Equalization Control: Training Control
//            - Bit0: Hot Reset
//            - Bit1: Disable Link
//            - Bit2: Loopback
//            - Bit3: Disable Scrambling (Gen2 only, Reserved for Gen3 TODO: Value ?!)
//            - Bit7:4: Reserved, set to 0
//
// Symbol6: Equalization Control:
//            - For Gen1/2:
//              + TS2 ID 0x4A encoded as D10.2
//              + EQ TS2 encoded as:
//                * Bit 0:2: Reciver preset hint
//                * Bit 3:6: Transimitter preset hint
//                * Bit 7: Equalization command
//            - For Gen3:
//              + Bit 0:5: Reserved TODO: Value ?!
//              + Bit6: Quiesce Guarantee
//              + Bit7: Request Equalization
//
// Symbol7:13: Equalization Control:
//            - For Gen1/2: TS2 ID 0x45 encoded as D5.2      
//            - For Gen3:  TS2 ID 0x45
//
// Symbol14:15: 
//            - For Gen1/2: TS1 ID 0x45 encoded as D5.2      
//            - For Gen3: TS2 ID 0x45, OR DC Blance Symbol

// TODO: What is bits values in TS related to Electrical part?
// TODO: If two devices tries to be downstream and publish link number, both of them will wait random time and try again? what is that time?
// TODO: DO we need to implement scrambling ?! from env -> pipe

// NOTE: Double number of signals
 
// N_FTS#, LINK#, LAN#, Supported Speeds, 


// RxData Valid
// allows the PHY to instruct the MAC to ignore the data interface for one clock cycle. A value of one indicates the MAC will use the data
// RxDataValid shall not assert when RXvalid is de-asserted in PHY modes that require the use of RxDataValid. 
// If a PHY supports the RxDataValid signal it shall keep RxDataValid asserted when the PHY is in a mode that does not require the signal. 
// The MAC may ignore RxDataValid when it is in a mode that does not require the signal. 

// RxElecIdle
// indicates receiver detection of an electrical idle. While deasserted with the PHY in P2 (PCI Express mode) 
// indicates detection of: PCI Express Mode: a beacon
// PCI Express Mode: It is required at the 5.0 GT/s, to GT/s, 16 GT/s, 32 GT/s, and 64 GT/s rates that a 
// MAC uses logic to detect electrical idle entry instead of relying on the RxElecldle signal. 

// RxDataK
// Data/Control bit for the symbols of receive data.A value of zero indicates a data byte;
// a value of 1 indicates a control byte. 
// Not used in PCI Express mode at 8 GT/s, 16 GT/s, 32 GT/s, or 64 GT/s

// RxStartBlock
// PCI Express Mode : Only used at the 8.0 GT/s, 16 GT/s, and 32 GT/s PCI Express signaling rates.
// This signal allows the PHY to tell the MAC the starting byte for a 128b block. The starting byte for a 128b block 
// must always start with byte 0 of the data interface. 
// Note: If there is an invalid sync header decoded on RxSyncHeader[3:0] and block alignment is still present
// ( RxValid == 1), then the PHY will assert RxStartBlock with the invalid sync header on RxSyncHeader[3:0] 
// RxStartBlock shall not assert when RxValid is de-asserted 

// RxSynchHeader
// PCI Express Mode: Only the lower two bits ([1:0]) are utilized. 
// Provides the sync header for the MAC to use with the next 128b block. 
// The MAC reads this value when the RxStartBlock signal is asserted. 
// This signal is only used at the 8.0 GT/s, 16 GT/s, and 32 GT/s signaling rates. 
// Note: The PHY shall pass blocks and headers normally across the PIPE interface 
// even if the decoded SyncHeader is invalid. 

// RxValid
// Indicates symbol lock and valid data on RxData and RxDataK and further qualifies RxDataValid when used. 
// PCI Express Mode at 8 GT/s, 16 GT/s, and 32 GT/s: When BlockAlignControl=1:
// RxValid indicates that the block aligner is conceptually in the "Aligned" state (see PCI Express Spec)
// If the block aligner transitions "Aligned" -> "Unaligned" state RxValid can deassert anywhere within a block
// If the block aligner transitions "Unaligned" -> "Aligned" state RxValid is asserted at the start of a block 
// Note that a PHY is not required to force its block aligner to the unaligned state when BlockAlignControl 
// transitions to one. When BlockAlignControl=0
// RxValid is constantly high indicating that the block aligner is conceptually in the "Locked" state 
// (see PCI Express Spec). RxValid can be dropped on detecting and elastic buffer underflow or overflow. 
// If de-asserted it must not re-assert while BlockAlignControl is de-asserted. 

// RxStatus
// Encodes receiver status and error codes for the received data stream when receiving data. 
// 000 : Received Data is ok
// 001 : 1 Skp Added 
// 010 : 1 Skp Removed
// 011 : Reciever Detected
// 100 : 8/10b or 128/130b decode error
// 101 : Elastic Buffer overflow
// 110 : Elastic Buffer underflow (not used if the bufffer operating in nominal empty mode)
// 111 : Recieve disparity error (Reserved if receive disparity error code is reported with 0b100)

// RxStandBy
// Controls whether the PHY RX is active when the PHY is in PO or POs. 0 — Active  , 1 — Standby 
// RxStandby is ignored when the PHY is in states other than PO or POs. 
// If RxStandby changes during 10Recal, RxEqEval, or RxEqTraining operations, 
// the PHY must abort the request and return the handshake acknowledgement. 

// RxStandbyStatus
// The PHY uses this signal to indicate its RxStandby state. 0 — Active 1 — Standby
// RxStandbyStatus reflects the state of the high speed receiver. 
// The high speed receiver is always off in PHY states that do not provide PCLK. 
// RxStandbyStatus is undefined when the power state is P1 or P2. 


`define True  1
`define False 0

typedef enum{
  TS1,
  TS2
} ts_type_t;

typedef enum{
  GEN1,
  GEN2,
  GEN3,
  GEN4,
  GEN5
} gen_t;

typedef struct {
  bit [7:0]             n_fts,
  bit                   use_n_fts,
  bit [7:0]             link_number,
  bit                   use_link_number,
  bit [7:0]             lane_number,
  bit                   use_lane_number,
  gen_t                 max_gen_suported,
  ts_type_t             ts_type
} ts_t;

<<<<<<< HEAD
task send_ts(TS_config config, int start_lane = 0, int end_lane = NUM_OF_LANES);
  //Symbol 0:
  @(posedge pclk);

endtask
||||||| b09a191
task send_ts(TS_config config, int start_lane = 0, int end_lane = NUM_OF_LANES);
=======
task send_ts(ts_t ts, int start_lane = 0, int end_lane = NUM_OF_LANES);
task send_tses(ts_t ts [], int start_lane = 0, int end_lane = NUM_OF_LANES);

task receive_ts(output ts_t ts, int start_lane = 0, int end_lane = NUM_OF_LANES);
task receive_tses(output ts_t ts [], int start_lane = 0, int end_lane = NUM_OF_LANES);
>>>>>>> origin/master
