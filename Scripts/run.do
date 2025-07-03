vlib work
vlog -f file.txt +define+SIM +cover
vsim -voptargs=+acc work.apb_top -cover

add wave -position 1 -color white sim:/apb_top/apb_vif/PCLK 
add wave -position 2 -radix unsigned sim:/apb_top/apb_vif/PRESETn 
add wave -position 3 -radix hexadecimal sim:/apb_top/apb_vif/PADDR 
add wave -position 4 -radix hexadecimal sim:/apb_top/duv/RegRDATA
add wave -position 5 -radix hexadecimal sim:/apb_top/apb_vif/PWRITE 
add wave -position 6 -radix hexadecimal sim:/apb_top/apb_vif/PWDATA 
add wave -position 7 -radix unsigned sim:/apb_top/apb_vif/PENABLE 
add wave -position 8 -radix unsigned sim:/apb_top/duv/slave/RegREADY
add wave -position 9 -radix unsigned sim:/apb_top/apb_vif/PSELx 
add wave -position 10 -radix hexadecimal sim:/apb_top/duv/RegADDR
add wave -position 11 -radix hexadecimal sim:/apb_top/duv/RegWDATA
add wave -position 12  sim:/apb_top/duv/slave/RegSTRB 
add wave -position 13 -radix unsigned sim:/apb_top/duv/RegWRITE
add wave -position 14 -radix unsigned sim:/apb_top/duv/RegENABLE
add wave -position 15 -radix unsigned sim:/apb_top/apb_vif/PREADY
add wave -position 16 sim:/apb_top/monitor/apb_sb.PREADY_ref
add wave -position 17 -radix hexadecimal sim:/apb_top/apb_vif/PRDATA 
add wave -position 18 -radix hexadecimal sim:/apb_top/monitor/apb_sb.PRDATA_ref
add wave -position 19 sim:/apb_top/duv/slave/PSLVERR
add wave -position 20 sim:/apb_top/monitor/apb_sb.PSLVERR_ref
add wave -position 21 -radix unsigned sim:/apb_top/duv/slave/current_state 
add wave -position 22 -radix unsigned sim:/shared_pkg::error_count 
add wave -position 23 -radix unsigned sim:/shared_pkg::correct_count

coverage save apb_top.ucdb -onexit
run -all

coverage report -output Scover_report.txt -srcfile=apb_slave.sv -srcfile=register_file.sv -detail -cvg -codeAll
coverage exclude -cvgpath {/coverage_pkg/apb_funct_coverage/apb_funct_cov_cg/\/coverage_pkg::apb_funct_coverage::apb_funct_cov_cg }
coverage report -detail -cvg -directive -comments -output fcover_report.txt {}
vcover report -html -output coverage_html apb_top.ucdb
