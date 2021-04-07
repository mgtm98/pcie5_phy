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
//              + Bit 0:5 Reserved TODO: Value ?!
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


typedef struct{

} TS1;

typedef struct{

} TS2;