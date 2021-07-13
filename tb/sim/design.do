onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /hdl_top/PIPE/PCLK
add wave -noupdate /hdl_top/PIPE/Reset
add wave -noupdate /hdl_top/LPIF/pl_linkup
add wave -noupdate /hdl_top/PIPE/PhyStatus
add wave -noupdate /hdl_top/PIPE/TxDetectRxLoopback
add wave -noupdate -radix binary /hdl_top/LPIF/lp_state_req
add wave -noupdate /hdl_top/LPIF/pl_state_sts
add wave -noupdate /hdl_top/PIPE/RxStatus
add wave -noupdate /hdl_top/PIPE/PowerDown
add wave -noupdate /hdl_top/LPIF/reset
add wave -noupdate /hdl_top/PIPE/TxElecIdle
add wave -noupdate /hdl_top/PIPE/RxData
add wave -noupdate /hdl_top/PIPE/RxDataValid
add wave -noupdate /hdl_top/PIPE/RxDataK
add wave -noupdate /hdl_top/PIPE/TxData
add wave -noupdate /hdl_top/PIPE/TxDataValid
add wave -noupdate /hdl_top/PIPE/TxDataK
add wave -noupdate /hdl_top/DUT/mainltssm/linkNumberInTx
add wave -noupdate /hdl_top/DUT/mainltssm/linkNumberInRx
add wave -noupdate /hdl_top/DUT/mainltssm/writeLinkNumberTx
add wave -noupdate /hdl_top/DUT/mainltssm/writeLinkNumberRx
add wave -noupdate /hdl_top/DUT/mainltssm/finishTx
add wave -noupdate /hdl_top/DUT/mainltssm/finishRx
add wave -noupdate /hdl_top/DUT/mainltssm/gotoTx
add wave -noupdate /hdl_top/DUT/mainltssm/gotoRx
add wave -noupdate /hdl_top/DUT/mainltssm/linkNumberOutTx
add wave -noupdate /hdl_top/DUT/mainltssm/linkNumberOutRx
add wave -noupdate /hdl_top/DUT/mainltssm/substateTx
add wave -noupdate /hdl_top/DUT/mainltssm/substateRx
add wave -noupdate /hdl_top/DUT/rx/rxltssm/masterRxLTSSM/substate
add wave -noupdate /hdl_top/DUT/rx/rxltssm/masterRxLTSSM/lastState
add wave -noupdate /hdl_top/DUT/rx/rxltssm/masterRxLTSSM/currentState
add wave -noupdate /hdl_top/DUT/rx/rxltssm/orderedSets
add wave -noupdate /hdl_top/DUT/rx/rxltssm/countUp
add wave -noupdate /hdl_top/DUT/rx/rxltssm/resetCounters
add wave -noupdate /hdl_top/DUT/rx/rxltssm/countersValues
add wave -noupdate /hdl_top/DUT/DEVICETYPE
add wave -noupdate /hdl_top/DUT/rx/DEVICETYPE
add wave -noupdate /hdl_top/DUT/TX/DEVICETYPE
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {34174 ns} 0} {{Cursor 2} {15295 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 247
configure wave -valuecolwidth 156
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {4324 ns} {37668 ns}
