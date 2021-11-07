//-----------------------------------------------------------------------------
// Author         :  Admin 
// E-Mail         :  contact@chipverify.com
// Description    :  Package of verification components
//-----------------------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

class spi_tx extends uvm_object;
   bit [31:0]  addr;
   bit [31:0]  data;

   `uvm_object_utils_begin (spi_tx)
      `uvm_field_int (addr, UVM_ALL_ON)
      `uvm_field_int (data, UVM_ALL_ON)
   `uvm_object_utils_end

   function new (string name="spi_tx");
      super.new (name);
   endfunction
endclass

class spi_driver extends uvm_driver;
   `uvm_component_utils (spi_driver)
   function new (string name="spi_driver", uvm_component parent);
      super.new (name, parent);
   endfunction

   virtual task main_phase (uvm_phase phase);
      `uvm_info ("spi_DRV", $sformatf ("Starting %s", this.get_type_name()), UVM_FULL)
   endtask
endclass

class spi_monitor extends uvm_monitor;
   `uvm_component_utils (spi_monitor)
   function new (string name="spi_monitor", uvm_component parent);
      super.new (name, parent);
   endfunction

   virtual task main_phase (uvm_phase phase);
      `uvm_info ("spi_MON", $sformatf ("Starting %s", this.get_type_name()), UVM_FULL)
   endtask
endclass

class spi_rw_seq extends uvm_sequence;
   `uvm_object_utils (spi_rw_seq)
   function new (string name = "spi_rw_seq");
      super.new (name);
   endfunction

   task body ();
      `uvm_info ("RW_SEQ", $sformatf ("Starting %s", this.get_type_name()), UVM_MEDIUM)
   endtask
endclass

class spi_reset_seq extends uvm_sequence;
   `uvm_object_utils (spi_reset_seq)
   function new (string name = "spi_reset_seq");
      super.new (name);
   endfunction

   task body ();
      `uvm_info ("RESET_SEQ", $sformatf ("Starting %s", this.get_type_name()), UVM_MEDIUM)
   endtask
endclass

class spi_tx_seq extends uvm_sequence;
   `uvm_object_utils (spi_tx_seq)
   function new (string name = "spi_tx_seq");
      super.new (name);
   endfunction

   task body ();
      `uvm_info ("tx_SEQ", $sformatf ("Starting %s", this.get_type_name()), UVM_MEDIUM)
   endtask
endclass


class spi_agent extends uvm_agent;
   `uvm_component_utils (spi_agent)
   
   spi_driver                 m_spi_drv;
   spi_monitor                m_spi_mon;
   uvm_sequencer              m_spi_seqr;

   function new (string name="spi_agent", uvm_component parent);
      super.new (name, parent);
   endfunction

   function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_spi_seqr  = uvm_sequencer#(uvm_sequence_item)::type_id::create ("m_spi_seqr", this);
      m_spi_drv   = spi_driver::type_id::create ("m_spi_drv", this);
      m_spi_mon   = spi_monitor::type_id::create ("m_spi_mon", this);
   endfunction

   function void connect_phase (uvm_phase phase);
      super.connect_phase (phase);
      m_spi_drv.seq_item_port.connect (m_spi_seqr.seq_item_export);
   endfunction

   virtual task main_phase (uvm_phase phase);
      `uvm_info ("spi_AGNT", $sformatf ("Starting %s", this.get_type_name()), UVM_FULL)
   endtask
endclass
