`include "uvm_macros.svh"
import uvm_pkg::*;

//_____let's make a tx packet _____//

class apb_tx extends uvm_object;
  bit [31:0] addr;
  bit [31:0] data;
  
  `uvm_object_utils_begin(apb_tx)
  `uvm_field_int(addr, UVM_ALL_ON)
  `uvm_field_int(data, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new (string name = "apb_tx");
    super.new(name);
  endfunction
  
endclass:apb_tx

//__________let's make a driver to drive this tx packet___________//
class apb_driver extends uvm_driver;
  `uvm_component_utils(apb_driver)
  
  function new (string name = "apb_driver", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual task main_phase(uvm_phase phase);
    `uvm_info("APB_DRV",$sformatf("Starting %s", this.get_type_name()),UVM_MEDIUM)
  endtask
endclass:apb_driver


class apb_rw_seq extends uvm_sequence;
  `uvm_object_utils(apb_rw_seq)
  
  function new(string name = "apb_rw_seq");
    super.new(name);
  endfunction
  
  
  task body();
    `uvm_info("APB_RW" , $sformatf("Starting %s", this.get_type_name()), UVM_MEDIUM)
  endtask
endclass:apb_rw_seq

class apb_reset_seq extends uvm_sequence;
  `uvm_object_utils(apb_reset_seq)
  
  function new(string name = "apb_reset_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info("APB_RESET", $sformatf("Starting %s", this.get_type_name()), UVM_MEDIUM)
  endtask
endclass:apb_reset_seq

class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)
  
  function new(string name = "apb_monitor",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual task main_phase(uvm_phase phase);
    `uvm_info("APB_MON",$sformatf("Starting %s", this.get_type_name()),UVM_MEDIUM)
  endtask
endclass:apb_monitor
  

class apb_agent extends uvm_agent;
  `uvm_component_utils(apb_agent)
  apb_driver m_apb_drv;
  apb_monitor m_apb_mon;
  uvm_sequencer m_apb_seqr;
  
  function new (string name = "apb_agent", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //sequences will be created in test
    
    // questa compile ERROR: Expected #() syntax as parameterized class prefix to '::' near "type_id"
    // xrun WARINING: This unadorned reference to a parameterized class (uvm_sequencer) is not legal. A class specialization of '#()' is assumed.
    m_apb_seqr = uvm_sequencer#(uvm_sequence_item)::type_id::create("m_apb_seqr",this);
    m_apb_drv = apb_driver::type_id::create("m_apb_drv",this);
    m_apb_mon = apb_monitor::type_id::create("m_apb_mon",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_apb_drv.seq_item_port.connect(m_apb_seqr.seq_item_export);
  endfunction
  
  virtual task main_phase(uvm_phase phase);
    `uvm_info("APB_AGENT",$sformatf("Starting %s", this.get_type_name()), UVM_MEDIUM)
  endtask
endclass:apb_agent
  
  
