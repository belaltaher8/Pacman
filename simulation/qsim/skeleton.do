onerror {exit -code 1}
vlib work
vlog -work work skeleton.vo
vlog -work work Waveform4.vwf.vt
vsim -novopt -c -t 1ps -L cycloneive_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate_ver -L altera_lnsim_ver work.VGA_clock_converter_vlg_vec_tst -voptargs="+acc"
vcd file -direction skeleton.msim.vcd
vcd add -internal VGA_clock_converter_vlg_vec_tst/*
vcd add -internal VGA_clock_converter_vlg_vec_tst/i1/*
run -all
quit -f
