//-----------------------------------------------------------------------------
// Author         :  Admin 
// E-Mail         :  contact@chipverify.com
// Description    :  Package of verification components
//-----------------------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;
 
class wb_tx extends uvm_object;
   bit [31:0]  addr;
   bit [31:0]  data;
 
   `uvm_object_utils_begin (wb_tx)
      `uvm_field_int (addr, UVM_ALL_ON)
      `uvm_field_int (data, UVM_ALL_ON)
   `uvm_object_utils_end
 
   function new (string name="wb_tx");
      super.new (name);
   endfunction
endclass
 
class wb_driver extends uvm_driver;
   `uvm_component_utils (wb_driver)
   function new (string name="wb_driver", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      `uvm_info ("wb_DRV", $sformatf ("Starting %s", this.get_type_name()), UVM_FULL)
   endtask
endclass
 
class wb_monitor extends uvm_monitor;
   `uvm_component_utils (wb_monitor)
   function new (string name="wb_monitor", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      `uvm_info ("wb_MON", $sformatf ("Starting %s", this.get_type_name()), UVM_FULL)
   endtask
endclass
 
class wb_rw_seq extends uvm_sequence;
   `uvm_object_utils (wb_rw_seq)
   function new (string name = "wb_rw_seq");
      super.new (name);
   endfunction
 
   task body ();
      `uvm_info ("RW_SEQ", $sformatf ("Starting %s", this.get_type_name()), UVM_MEDIUM)
   endtask
endclass
 
class wb_reset_seq extends uvm_sequence;
   `uvm_object_utils (wb_reset_seq)
   function new (string name = "wb_reset_seq");
      super.new (name);
   endfunction
 
   task body ();
      `uvm_info ("RESET_SEQ", $sformatf ("Starting %s", this.get_type_name()), UVM_MEDIUM)
   endtask
endclass
 
class wb_agent extends uvm_agent;
   `uvm_component_utils (wb_agent)
 
   wb_driver                 m_wb_drv;
   wb_monitor                m_wb_mon;
   uvm_sequencer              m_wb_seqr;
 
   function new (string name="wb_agent", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   function void build_phase (uvm_phase phase);
      super.build_phase (phase);

      // questa compile ERROR: Expected #() syntax as parameterized class prefix to '::' near "type_id"
      // xrun WARINING: This unadorned reference to a parameterized class (uvm_sequencer) is not legal. A class specialization of '#()' is assumed.
      m_wb_seqr  = uvm_sequencer#(uvm_sequence_item)::type_id::create ("m_wb_seqr", this);
      m_wb_drv   = wb_driver::type_id::create ("m_wb_drv", this);
      m_wb_mon   = wb_monitor::type_id::create ("m_wb_mon", this);
   endfunction
 
   function void connect_phase (uvm_phase phase);
      super.connect_phase (phase);
      m_wb_drv.seq_item_port.connect (m_wb_seqr.seq_item_export);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      `uvm_info ("wb_AGNT", $sformatf ("Starting %s", this.get_type_name()), UVM_FULL)
   endtask
endclass
 

 
