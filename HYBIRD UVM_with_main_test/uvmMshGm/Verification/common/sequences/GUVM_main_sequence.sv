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
  //B.seq_no = 2;
  //C = arb_seq::type_id::create("C");
 // C.seq_no = 3;
 //constraint seq_options {random_seq inside {Add,Branch_if_equal}}; 
      /*start_item(random_seq);

      if (!random_seq.randomize()) begin
        `uvm_error("Main Sequence", "Randomize failed.");
      end

      finish_item(req);*/
        fork
  begin
    Add.start(m_sequencer, this);
	Branch_if_equal.start(m_sequencer, this);
	load.start(m_sequencer, this);
   
  end
       join_any
       
   
 
      
 
  
  
  
  
endtask: body
 
endclass: GUVM_main_sequence

/*class GUVM_rand_sequence extends GUVM_main_sequence #(GUVM_sequence_item);
 
  //factory registration
  `uvm_object_utils(GUVM_rand_sequence)
 
 /// Sub-sequences class handle declaration
 //GUVM_sequence Add, Branch, Branch_if_equal;
 //rand GUVM_sequence random_seq;
 
 /// Constructor 
  function new(string name = "GUVM_rand_sequence");
  super.new(name);
 endfunction: new
 GUVM_sequence xxx;
 GUVM_main_sequence req_seq;
task body;
 //Add = add_sequence::type_id::create("Add");
  //A.seq_no = 1;
 //Branch_if_equal = bie_sequence::type_id::create("Branch_if_equal");
  //B.seq_no = 2;
  //C = arb_seq::type_id::create("C");
 // C.seq_no = 3;
 constraint seq_options {random_seq inside {Add,Branch_if_equal}}; 
 req_seq= GUVM_main_sequence::type_id::create("req_seq");
      //start_item(req_seq);

      if (!req_seq.randomize()) begin
        `uvm_error("Main Sequence", "Randomize failed.");
      end
      xxx = req_seq.random_seq;
      //finish_item(req_seq);
    req_seq.start(m_sequencer);
  
  
  
  
endtask: body
 
endclass: GUVM_rand_sequence*/