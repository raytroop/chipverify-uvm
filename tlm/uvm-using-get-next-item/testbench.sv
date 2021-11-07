// https://www.chipverify.com/uvm/uvm-using-get-next-item

import uvm_pkg::*;
`include "uvm_macros.svh"

// Note that this class is dervide from "uvm_sequence_item"
class my_data extends uvm_sequence_item;
  rand bit [7:0]   data;
  rand bit [7:0]   addr;

  // Rest of the class contents come here ...

  `uvm_object_utils(my_data)

  function new(string name="my_data");
    super.new(name);
  endfunction : new
endclass

class my_driver extends uvm_driver #(my_data);
  `uvm_component_utils (my_driver)
  // Other parts of the driver code if they exist

  function new(string name="my_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
      // 1. Get the next available item from the sequencer. If none exists, then wait until
      // next item is available -> this is blocking in nature
      `uvm_info ("DRIVER", $sformatf ("Waiting for data from sequencer"), UVM_MEDIUM)
      seq_item_port.get_next_item(req);

      // 2. Let us assume that the driver actively does the pin wiggling of the DUT during this time and 
      // consider it takes 20ns
      `uvm_info ("DRIVER", $sformatf ("Start driving tx addr=0x%0h data=0x%0h", req.addr, req.data), UVM_MEDIUM)
      #20;

      // 3. After the driver has driven all data to the DUT, it should let the sequencer know that it finished 
      // driving the transaction by calling "item_done". Optionally the response packet can be passed along with
      // the item_done method call and it will be placed in the sequencer's response FIFO
      `uvm_info ("DRIVER", $sformatf ("Finish driving tx addr=0x%0h data=0x%0h", req.addr, req.data), UVM_MEDIUM)
      seq_item_port.item_done();
    end
  endtask
endclass

class my_sequence extends uvm_sequence #(my_data);
  // Rest of the sequence code

  `uvm_object_utils(my_sequence)

  function new(string name="my_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    repeat(2) begin
      // 1. Create a sequence item of the given type
      req = my_data::type_id::create("tx");
      `uvm_info ("SEQ", $sformatf("About to call start_item"), UVM_MEDIUM)

      // 2. Start the item on the sequencer which will send this to the driver
      start_item(req);
      `uvm_info ("SEQ", $sformatf("start_item() fn call done"), UVM_MEDIUM)

      // 3. Do some late randomization to create a different content in this transaction object
      req.randomize();
      `uvm_info ("SEQ", $sformatf("tx randomized with addr=0x%0h data=0x%0h", req.addr, req.data), UVM_MEDIUM)

      // 4. Call finish_item to let driver continue driving the transaction object or sequence item
      // !!! `finish_item` is blocking call and block forward until driver's `item_done`
      finish_item(req);
      `uvm_info ("SEQ", $sformatf("finish_item() fn call done"), UVM_MEDIUM)
    end
  endtask
endclass

class base_test extends uvm_test;
  // Rest of the test code is here

  // The sequencer is parameterized to accept objects of type "my_data" only
  my_driver                	m_drv0;
  uvm_sequencer #(my_data) 	m_seqr0;
  my_sequence   				m_seq;

  `uvm_component_utils(base_test)

  function new(string name="base_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  // Build the sequencer and driver components
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_drv0 = my_driver::type_id::create ("m_drv0", this);
    m_seqr0 = uvm_sequencer#(my_data)::type_id::create ("m_seqr0", this);
  endfunction

  // Connect the sequencer "export" to the driver's "port"
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase (phase);
    m_drv0.seq_item_port.connect (m_seqr0.seq_item_export);
  endfunction

  // Start the sequence on the given sequencer
  virtual task run_phase(uvm_phase phase);
    m_seq = my_sequence::type_id::create("m_seq");
    phase.raise_objection(this);
    m_seq.start(m_seqr0);
    phase.drop_objection(this);
  endtask
endclass


module tb_top;

  initial begin
    run_test("base_test");
  end

endmodule
