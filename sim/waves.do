# activate waveform simulation

view wave

# format signal names in waveform

configure wave -signalnamewidth 1
configure wave -timeline 0
configure wave -timelineunits us

# add signals to waveform

add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/CLOCK_50_I
add wave -bin UUT/resetn
add wave UUT/top_state
add wave -uns UUT/UART_timer

add wave -divider -height 10 {SRAM signals}
add wave -uns UUT/SRAM_address
add wave -hex UUT/SRAM_write_data
add wave -bin UUT/SRAM_we_n
add wave -hex UUT/SRAM_read_data

add wave -divider -height 10 {VGA signals}
add wave -bin UUT/VGA_unit/VGA_HSYNC_O
add wave -bin UUT/VGA_unit/VGA_VSYNC_O
add wave -uns UUT/VGA_unit/pixel_X_pos
add wave -uns UUT/VGA_unit/pixel_Y_pos
add wave -hex UUT/VGA_unit/VGA_red
add wave -hex UUT/VGA_unit/VGA_green
add wave -hex UUT/VGA_unit/VGA_blue

add wave -divider -height 10 {General signals}
add wave -hex UUT/m1_unit/state
add wave -hex UUT/m1_unit/col_counter

add wave -divider -height 10 {Multiplication signals}
add wave -dec UUT/m1_unit/Multi_op_1_1
add wave -dec UUT/m1_unit/Multi_op_1_2
add wave -dec UUT/m1_unit/Multi_op_2_1
add wave -dec UUT/m1_unit/Multi_op_2_2
add wave -dec UUT/m1_unit/Multi_result_long1
add wave -dec UUT/m1_unit/Multi_result_long2


add wave -divider -height 10 {Y signals}
add wave -dec UUT/m1_unit/Y_address
add wave -dec UUT/m1_unit/Y_even
add wave -dec UUT/m1_unit/Y_odd

add wave -divider -height 10 {U signals}
add wave -dec UUT/m1_unit/U_address
add wave -dec UUT/m1_unit/U_even
add wave -dec UUT/m1_unit/U_odd
add wave -dec UUT/m1_unit/U_shift
add wave -dec UUT/m1_unit/U_odd_accum

add wave -divider -height 10 {V signals}
add wave -dec UUT/m1_unit/V_address
add wave -dec UUT/m1_unit/V_even
add wave -dec UUT/m1_unit/V_odd
add wave -dec UUT/m1_unit/V_shift
add wave -dec UUT/m1_unit/V_odd_accum

add wave -divider -height 10 {RGB signals}
add wave -dec UUT/m1_unit/RGB_address
add wave -dec UUT/m1_unit/RGB_red
add wave -dec UUT/m1_unit/RGB_green
add wave -dec UUT/m1_unit/RGB_green_buf
add wave -dec UUT/m1_unit/RGB_blue
add wave -dec UUT/m1_unit/RGB_blue_buf








