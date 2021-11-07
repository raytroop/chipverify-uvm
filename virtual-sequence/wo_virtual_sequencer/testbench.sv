`timescale 1ns/1ps

`include "apb_agent.sv"
`include "spi_agent.sv"
`include "wb_agent.sv"

import uvm_pkg::*;
`include "uvm_macros.svh"

class my_env extends uvm_env;
  `uvm_component_utils(my_env)
  function new (string name = "my_env", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  //_________________agents instantiated______________________//
  
  apb_agent m_apb_agent;
  wb_agent m_wb_agent;
  spi_agent m_spi_agent;
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_apb_agent = apb_agent::type_id::create("m_apb_agent",this);
    m_wb_agent = wb_agent::type_id::create("m_wb_agent",this);
    m_spi_agent = spi_agent::type_id::create("m_spi_agent",this);
  endfunction
endclass:my_env
  
  //here individual physical sequencer handles are placed within my virtual sequence
  //a base virtual sequence class can be declared just to hold these handles
  //but in that case it is better to declare a sequencer instead of a sequence
  //in test these handles should be connected to actual handles
  
  class my_virtual_seq extends uvm_sequence;
    `uvm_object_utils(my_virtual_seq)
    
    //_____________declare those sequencers within this sequence_________________//
    
    uvm_sequencer m_apb_seqr;//pointing to null
    uvm_sequencer m_wb_seqr;
    uvm_sequencer m_spi_seqr;
    
    //__________instantiate individual sequences inside my_virtual_seq______//
    
    apb_rw_seq m_apb_rw_seq;
    wb_reset_seq m_wb_reset_seq;
    spi_tx_seq m_spi_tx_seq;
    
    function new(string name = "my_virtual_seq");
      super.new(name);
    endfunction
    
    virtual task body ();
      m_apb_rw_seq = apb_rw_seq::type_id::create("m_apb_rw_seq");
      m_wb_reset_seq = wb_reset_seq::type_id::create("m_wb_reset_seq");
      m_spi_tx_seq = spi_tx_seq::type_id::create("m_spi_tx_seq");
      
      `uvm_info("VSEQ", "virtual seq are being started on seqrs", UVM_MEDIUM)
      
      fork
        m_wb_reset_seq.start(m_wb_seqr);
        #20 m_apb_rw_seq.start(m_apb_seqr);
      join
      #10;
      m_spi_tx_seq.start(m_spi_seqr);
      
      `uvm_info("VSEQ", "Sequences have started on seqrs",UVM_MEDIUM)
    endtask
  endclass:my_virtual_seq

class my_test extends uvm_test;
  `uvm_component_utils(my_test)
  
  my_env m_my_env;
  my_virtual_seq m_my_virtual_seq;
  
  function new (string name = "my_test",uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_my_env = my_env::type_id::create("m_my_env",this);
    m_my_virtual_seq = my_virtual_seq::type_id::create("m_my_virtual_seq");
  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction
  
  virtual task main_phase(uvm_phase phase);
    super.main_phase(phase);
    
    phase.raise_objection(this);
    
    //individual seququencers inside my_virtual_seq needs to be connected to original seqrs.
    
    m_my_virtual_seq.m_apb_seqr = m_my_env.m_apb_agent.m_apb_seqr;
    m_my_virtual_seq.m_wb_seqr = m_my_env.m_wb_agent.m_wb_seqr;
    m_my_virtual_seq.m_spi_seqr = m_my_env.m_spi_agent.m_spi_seqr;
    
    m_my_virtual_seq.start(null); //no sequencer is there
    
    phase.drop_objection(this);
    
  endtask:main_phase
  
  virtual task shutdown_phase(uvm_phase phase);
    super.shutdown_phase(phase);
    `uvm_info("SHUTTING DOWN","shutting down test...............",UVM_MEDIUM)
  endtask
endclass:my_test

module tb_top;
   initial begin
      run_test ("my_test");
   end
 
endmodule
 
 
 

 
