class GUVM_main_sequence extends uvm_sequence #(GUVM_sequence_item);
 
  //factory registration
  `uvm_object_utils(GUVM_main_sequence)
 
 /// Sub-sequences class handle declaration
 GUVM_sequence Add, Branch, Branch_if_equal,load;
 rand GUVM_sequence random_seq;
 
 /// Constructor 
  function new(string name = "GUVM_main_sequence");
  super.new(name);
 endfunction: new
 
 
task body;
 Add = add_sequence::type_id::create("Add");
 
 Branch_if_equal = bie_sequence::type_id::create("Branch_if_equal");
 load=load_sequence::type_id::create("load");

        fork
  begin
    Add.start(m_sequencer, this);
	Branch_if_equal.start(m_sequencer, this);
	load.start(m_sequencer, this);
   
  end
       join_any
       
   
 
      
 
  
  
  
  
endtask: body
 
endclass: GUVM_main_sequence

