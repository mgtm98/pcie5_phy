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
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 149
configure wave -valuecolwidth 109
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
WaveRestoreZoom {0 ns} {57 ns}
run -all