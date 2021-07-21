onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /hdl_top/PIPE/PCLK
add wave -noupdate /hdl_top/PIPE/Reset
add wave -noupdate /hdl_top/LPIF/pl_linkup
add wave -noupdate /hdl_top/LPIF/lp_data
add wave -noupdate /hdl_top/LPIF/lp_valid
add wave -noupdate /hdl_top/LPIF/lp_irdy
add wave -noupdate /hdl_top/LPIF/pl_trdy
add wave -noupdate /hdl_top/LPIF/lp_tlp_start
add wave -noupdate /hdl_top/LPIF/lp_tlp_end
add wave -noupdate /hdl_top/LPIF/lp_dllp_start
add wave -noupdate /hdl_top/LPIF/lp_dllp_end
add wave -noupdate /hdl_top/LPIF/lp_tlpedb
add wave -noupdate /hdl_top/LPIF/pl_data
add wave -noupdate /hdl_top/LPIF/pl_valid
add wave -noupdate /hdl_top/LPIF/pl_tlp_start
add wave -noupdate /hdl_top/LPIF/pl_tlp_end
add wave -noupdate /hdl_top/LPIF/pl_dllp_start
add wave -noupdate /hdl_top/LPIF/pl_dllp_end
add wave -noupdate /hdl_top/LPIF/pl_tlpedb
add wave -noupdate /hdl_top/PIPE/PhyStatus
add wave -noupdate /hdl_top/PIPE/TxDetectRxLoopback
add wave -noupdate -radix binary /hdl_top/LPIF/lp_state_req
add wave -noupdate /hdl_top/LPIF/pl_state_sts
add wave -noupdate /hdl_top/PIPE/RxStatus
add wave -noupdate /hdl_top/PIPE/PowerDown
add wave -noupdate /hdl_top/LPIF/reset
add wave -noupdate /hdl_top/PIPE/TxElecIdle
add wave -noupdate /hdl_top/PIPE/RxData
add wave -noupdate /hdl_top/PIPE/RxDataK
add wave -noupdate /hdl_top/PIPE/RxDataValid
add wave -noupdate /hdl_top/PIPE/RxStartBlock
add wave -noupdate /hdl_top/PIPE/RxSyncHeader
add wave -noupdate /hdl_top/PIPE/TxData
add wave -noupdate /hdl_top/PIPE/TxDataK
add wave -noupdate /hdl_top/PIPE/TxDataValid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 149
configure wave -valuecolwidth 156
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {7 ns} {29 ns}
