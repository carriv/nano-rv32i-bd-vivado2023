# -----------------------------------------------------------------------------
# Recrea el diseño de bloques design_1 (SoC mínimo del Lab 3) en el proyecto
# Vivado ABIERTO, más su wrapper, y fija los tops de síntesis y simulación.
#
# Extraído de project_1/project_1.tcl (generado con Vivado 2024.1) para poder
# usarlo en un proyecto limpio de Vivado 2023.2. Cambios respecto al original:
#   - solo se conserva el procedimiento cr_bd_design_1 (no crea el proyecto)
#   - la ruta del .coe ya no es /tmp/nano/... sino relativa a este script
#
# Requisitos: el proyecto ya contiene hw/*.v (incluidos nano_rv32i.v y
# cycle_counter_trigger.v), el .xdc y tb/design_tb.v en sim_1.
#
# Uso (consola Tcl de Vivado, con el proyecto abierto):
#   source <ruta>/nano_rv32i/scripts/create_bd_design_1.tcl
# -----------------------------------------------------------------------------

set ::nano_root [file normalize [file join [file dirname [info script]] ..]]
set ::nano_coe  [file join $::nano_root coe init_mem.coe]

if { [llength [get_files -quiet design_1.bd]] > 0 } {
    error "design_1.bd ya existe en el proyecto; bórralo antes de recrearlo."
}

proc cr_bd_design_1 { parentCell } {
# The design that will be created by this Tcl proc contains the following 
# module references:
# nano_rv32i, cycle_counter_trigger



  # CHANGE DESIGN NAME HERE
  set design_name design_1

  common::send_gid_msg -ssname BD::TCL -id 2010 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

  create_bd_design $design_name

  set bCheckIPsPassed 1
  ##################################################################
  # CHECK IPs
  ##################################################################
  set bCheckIPs 1
  if { $bCheckIPs == 1 } {
     set list_check_ips "\ 
  xilinx.com:ip:axi_gpio:2.0\
  xilinx.com:ip:blk_mem_gen:8.4\
  xilinx.com:ip:util_vector_logic:2.0\
  xilinx.com:ip:xlconstant:1.1\
  "

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

  }

  ##################################################################
  # CHECK Modules
  ##################################################################
  set bCheckModules 1
  if { $bCheckModules == 1 } {
     set list_check_mods "\ 
  nano_rv32i\
  cycle_counter_trigger\
  "

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

  if { $bCheckIPsPassed != 1 } {
    common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
    return 3
  }

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set clk_i_0 [ create_bd_port -dir I -type clk clk_i_0 ]
  set rst_n_i_0 [ create_bd_port -dir I -type rst rst_n_i_0 ]
  set gpio_io_o_0 [ create_bd_port -dir O -from 15 -to 0 gpio_io_o_0 ]

  # Create instance: nano_rv32i_0, and set properties
  set block_name nano_rv32i
  set block_cell_name nano_rv32i_0
  if { [catch {set nano_rv32i_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $nano_rv32i_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {16} \
  ] $axi_gpio_0


  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property -dict [list \
    CONFIG.Coe_File $::nano_coe \
    CONFIG.Load_Init_File {true} \
    CONFIG.Memory_Type {Single_Port_ROM} \
  ] $blk_mem_gen_0


  # Create instance: blk_mem_gen_1, and set properties
  set blk_mem_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_1 ]

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $util_vector_logic_0


  # Create instance: util_vector_logic_1, and set properties
  set util_vector_logic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_1 ]
  set_property CONFIG.C_OPERATION {or} $util_vector_logic_1


  # Create instance: cycle_counter_trigger_0, and set properties
  set block_name cycle_counter_trigger
  set block_cell_name cycle_counter_trigger_0
  if { [catch {set cycle_counter_trigger_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $cycle_counter_trigger_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property CONFIG.CONST_VAL {0} $xlconstant_0


  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {15} \
    CONFIG.CONST_WIDTH {4} \
  ] $xlconstant_1


  # Create port connections
  connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_ports gpio_io_o_0]
  connect_bd_net -net axi_gpio_0_s_axi_arready [get_bd_pins axi_gpio_0/s_axi_arready] [get_bd_pins nano_rv32i_0/s_axi_arready_i]
  connect_bd_net -net axi_gpio_0_s_axi_awready [get_bd_pins axi_gpio_0/s_axi_awready] [get_bd_pins nano_rv32i_0/s_axi_awready_i]
  connect_bd_net -net axi_gpio_0_s_axi_bvalid [get_bd_pins axi_gpio_0/s_axi_bvalid] [get_bd_pins nano_rv32i_0/s_axi_bvalid_i]
  connect_bd_net -net axi_gpio_0_s_axi_rdata [get_bd_pins axi_gpio_0/s_axi_rdata] [get_bd_pins nano_rv32i_0/s_axi_rdata_i]
  connect_bd_net -net axi_gpio_0_s_axi_rvalid [get_bd_pins axi_gpio_0/s_axi_rvalid] [get_bd_pins nano_rv32i_0/s_axi_rvalid_i]
  connect_bd_net -net axi_gpio_0_s_axi_wready [get_bd_pins axi_gpio_0/s_axi_wready] [get_bd_pins nano_rv32i_0/s_axi_wready_i]
  connect_bd_net -net blk_mem_gen_0_douta [get_bd_pins blk_mem_gen_0/douta] [get_bd_pins nano_rv32i_0/i_data_i]
  connect_bd_net -net blk_mem_gen_0_rsta_busy [get_bd_pins blk_mem_gen_0/rsta_busy] [get_bd_pins util_vector_logic_1/Op2]
  connect_bd_net -net blk_mem_gen_1_douta [get_bd_pins blk_mem_gen_1/douta] [get_bd_pins nano_rv32i_0/d_data_i]
  connect_bd_net -net blk_mem_gen_1_rsta_busy [get_bd_pins blk_mem_gen_1/rsta_busy] [get_bd_pins util_vector_logic_1/Op1]
  connect_bd_net -net cycle_counter_trigger_0_trigger_out [get_bd_pins cycle_counter_trigger_0/trigger_out] [get_bd_pins nano_rv32i_0/rst_n_i]
  connect_bd_net -net nano_rv32i_0_d_addr_o [get_bd_pins nano_rv32i_0/d_addr_o] [get_bd_pins blk_mem_gen_1/addra]
  connect_bd_net -net nano_rv32i_0_d_data_o [get_bd_pins nano_rv32i_0/d_data_o] [get_bd_pins blk_mem_gen_1/dina]
  connect_bd_net -net nano_rv32i_0_d_we_o [get_bd_pins nano_rv32i_0/d_we_o] [get_bd_pins blk_mem_gen_1/wea]
  connect_bd_net -net nano_rv32i_0_i_addr_o [get_bd_pins nano_rv32i_0/i_addr_o] [get_bd_pins blk_mem_gen_0/addra]
  connect_bd_net -net nano_rv32i_0_i_rd_o [get_bd_pins nano_rv32i_0/i_rd_o] [get_bd_pins blk_mem_gen_0/ena]
  connect_bd_net -net nano_rv32i_0_s_axi_araddr_o [get_bd_pins nano_rv32i_0/s_axi_araddr_o] [get_bd_pins axi_gpio_0/s_axi_araddr]
  connect_bd_net -net nano_rv32i_0_s_axi_arvalid_o [get_bd_pins nano_rv32i_0/s_axi_arvalid_o] [get_bd_pins axi_gpio_0/s_axi_arvalid]
  connect_bd_net -net nano_rv32i_0_s_axi_awaddr_o [get_bd_pins nano_rv32i_0/s_axi_awaddr_o] [get_bd_pins axi_gpio_0/s_axi_awaddr]
  connect_bd_net -net nano_rv32i_0_s_axi_awvalid_o [get_bd_pins nano_rv32i_0/s_axi_awvalid_o] [get_bd_pins axi_gpio_0/s_axi_awvalid]
  connect_bd_net -net nano_rv32i_0_s_axi_bready_o [get_bd_pins nano_rv32i_0/s_axi_bready_o] [get_bd_pins axi_gpio_0/s_axi_bready]
  connect_bd_net -net nano_rv32i_0_s_axi_rready_o [get_bd_pins nano_rv32i_0/s_axi_rready_o] [get_bd_pins axi_gpio_0/s_axi_rready]
  connect_bd_net -net nano_rv32i_0_s_axi_wdata_o [get_bd_pins nano_rv32i_0/s_axi_wdata_o] [get_bd_pins axi_gpio_0/s_axi_wdata]
  connect_bd_net -net nano_rv32i_0_s_axi_wvalid_o [get_bd_pins nano_rv32i_0/s_axi_wvalid_o] [get_bd_pins axi_gpio_0/s_axi_wvalid]
  connect_bd_net -net s_axi_aclk_0_1 [get_bd_ports clk_i_0] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins blk_mem_gen_0/clka] [get_bd_pins nano_rv32i_0/clk_i] [get_bd_pins blk_mem_gen_1/clka] [get_bd_pins cycle_counter_trigger_0/clk]
  connect_bd_net -net s_axi_aresetn_0_1 [get_bd_ports rst_n_i_0] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins util_vector_logic_0/Op1] [get_bd_pins cycle_counter_trigger_0/reset_n]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins util_vector_logic_0/Res] [get_bd_pins blk_mem_gen_0/rsta] [get_bd_pins blk_mem_gen_1/rsta]
  connect_bd_net -net util_vector_logic_1_Res [get_bd_pins util_vector_logic_1/Res] [get_bd_pins nano_rv32i_0/rsta_busy_i]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins xlconstant_0/dout] [get_bd_pins nano_rv32i_0/core_stop_i]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins xlconstant_1/dout] [get_bd_pins axi_gpio_0/s_axi_wstrb]

  # Create address segments

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_ScaleFactor":"0.79893",
   "Default View_TopLeft":"632,99",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.7.1 2023-07-26 3bc4126617 VDI=43 GEI=38 GUI=JA:21.0 TLS
#  -string -flagsOSRD
preplace port port-id_clk_i_0 -pg 1 -lvl 0 -x 0 -y 290 -defaultsOSRD
preplace port port-id_rst_n_i_0 -pg 1 -lvl 0 -x 0 -y 560 -defaultsOSRD
preplace portBus gpio_io_o_0 -pg 1 -lvl 6 -x 1930 -y 410 -defaultsOSRD
preplace inst nano_rv32i_0 -pg 1 -lvl 4 -x 1230 -y 220 -defaultsOSRD
preplace inst axi_gpio_0 -pg 1 -lvl 5 -x 1740 -y 400 -defaultsOSRD
preplace inst blk_mem_gen_0 -pg 1 -lvl 2 -x 510 -y 730 -defaultsOSRD
preplace inst blk_mem_gen_1 -pg 1 -lvl 2 -x 510 -y 320 -defaultsOSRD
preplace inst util_vector_logic_0 -pg 1 -lvl 1 -x 170 -y 560 -defaultsOSRD
preplace inst util_vector_logic_1 -pg 1 -lvl 3 -x 810 -y 330 -defaultsOSRD
preplace inst cycle_counter_trigger_0 -pg 1 -lvl 3 -x 810 -y 670 -defaultsOSRD
preplace inst xlconstant_0 -pg 1 -lvl 3 -x 810 -y 130 -defaultsOSRD
preplace inst xlconstant_1 -pg 1 -lvl 4 -x 1230 -y 530 -defaultsOSRD
preplace netloc axi_gpio_0_gpio_io_o 1 5 1 N 410
preplace netloc axi_gpio_0_s_axi_arready 1 3 2 1040 410 1500
preplace netloc axi_gpio_0_s_axi_awready 1 3 2 1040 30 1550
preplace netloc axi_gpio_0_s_axi_bvalid 1 3 2 1020 20 1530J
preplace netloc axi_gpio_0_s_axi_rdata 1 3 2 1030 420 1550J
preplace netloc axi_gpio_0_s_axi_rvalid 1 3 2 1000 450 NJ
preplace netloc axi_gpio_0_s_axi_wready 1 3 2 1010 430 1470J
preplace netloc blk_mem_gen_0_douta 1 1 3 350 190 NJ 190 960
preplace netloc blk_mem_gen_0_rsta_busy 1 2 1 640 340n
preplace netloc blk_mem_gen_1_douta 1 1 3 380 200 NJ 200 990J
preplace netloc blk_mem_gen_1_rsta_busy 1 2 1 N 320
preplace netloc cycle_counter_trigger_0_trigger_out 1 3 1 980 130n
preplace netloc nano_rv32i_0_d_addr_o 1 1 4 370 440 NJ 440 NJ 440 1430
preplace netloc nano_rv32i_0_d_data_o 1 1 4 360 10 NJ 10 NJ 10 1420
preplace netloc nano_rv32i_0_d_we_o 1 1 4 360 460 NJ 460 NJ 460 1420
preplace netloc nano_rv32i_0_i_addr_o 1 1 4 370 840 NJ 840 NJ 840 1450
preplace netloc nano_rv32i_0_i_rd_o 1 1 4 380 470 NJ 470 NJ 470 1440
preplace netloc nano_rv32i_0_s_axi_araddr_o 1 4 1 1470 250n
preplace netloc nano_rv32i_0_s_axi_arvalid_o 1 4 1 1510 290n
preplace netloc nano_rv32i_0_s_axi_awaddr_o 1 4 1 1540 210n
preplace netloc nano_rv32i_0_s_axi_awvalid_o 1 4 1 1520 230n
preplace netloc nano_rv32i_0_s_axi_bready_o 1 4 1 1510 350n
preplace netloc nano_rv32i_0_s_axi_rready_o 1 4 1 1490 330n
preplace netloc nano_rv32i_0_s_axi_wdata_o 1 4 1 1460 250n
preplace netloc nano_rv32i_0_s_axi_wvalid_o 1 4 1 1480 270n
preplace netloc s_axi_aclk_0_1 1 0 5 NJ 290 330 590 650 590 970 590 1520J
preplace netloc s_axi_aresetn_0_1 1 0 5 20 620 NJ 620 660 600 NJ 600 1550
preplace netloc util_vector_logic_0_Res 1 1 1 340 360n
preplace netloc util_vector_logic_1_Res 1 3 1 990 210n
preplace netloc xlconstant_0_dout 1 3 1 960J 130n
preplace netloc xlconstant_1_dout 1 4 1 1460J 510n
levelinfo -pg 1 0 170 510 810 1230 1740 1930
pagesize -pg 1 -db -bbox -sgen -170 0 2110 860
"
}

  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
  close_bd_design $design_name 
}
# End of cr_bd_design_1()

cr_bd_design_1 ""

# Wrapper HDL del diseño de bloques
set wrapper_path [make_wrapper -fileset sources_1 -files [get_files -norecurse design_1.bd] -top]
add_files -norecurse -fileset sources_1 $wrapper_path

# Tops: síntesis = wrapper del SoC, simulación = testbench del sistema
set_property top design_1_wrapper [get_filesets sources_1]
set_property top testbench_design_1 [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "design_1 creado. Top de simulación: testbench_design_1"
