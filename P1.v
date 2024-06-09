//Lina Abufarha
//1211968  
//Section 2
////////////////////////////////////////////--Project #1--////////////////////////////////////////////////////	 
////Define instruction names...
`define ADD 6'b000001
`define XOR 6'b000010 
`define OR  6'b000011
`define MIN 6'b000100 
`define AND 6'b000101
`define SUB 6'b000110	
`define MAX	6'b000111	
`define NEG 6'b001000	 
`define AGG 6'b001011 
`define ABS	6'b001101
`define NOT	6'b001111
/////////////////////////////////////////////////( -The ALU- )//////////////////////////////////////////////////////////	
module alu(opcode,a,b,result);	 
	
	input [5:0] opcode;
	input signed [31:0] a,b;					
	output reg signed [31:0] result;
	
	always @(*)begin 
		
		case(opcode)
			
			`ADD : result = a + b ;             //1 
			`XOR : result = a ^ b;	            //2	 a xor b
			`OR  :	result = a | b;             //3	 a or b
			`MIN :	result = (a < b) ? a : b;   //4  min(a, b)
			`AND :	result = a & b;             //5  a and b
			`SUB : result = a - b;              //6
			`MAX :	result = (a > b) ? a : b;   //7	 max(a, b)	
			`NEG :	result = -a;                //8
			`AGG :	result = (a + b) >> 1;      //11  avg(a, b)
			`ABS :	result = (a >= 0) ? a :-a ; //13 |a|
			`NOT :	result = ~a ;               //15  not a
																						
		    default: result = 32'b0;  // Default result = 0
		 endcase
	
	   end	
	
endmodule	

module test_alu; //////////////Stimulus for testing alu 	 
	
  // Inputs
  reg [5:0] opcode;
  reg signed [31:0] a,b;	   
  
  // Outputs
  wire signed [31:0] result; 
  
  alu U1 (.opcode(opcode),.a(a),.b(b),.result(result));	  
  
  initial begin
	  a = -13;	    
	  b = 54;  
	  opcode = 6'b000000; 	
	  repeat (16)
    #10 opcode = opcode + 1 ;   
	
	 #100 $finish; 
  end	

	always @(opcode ) begin	
    	#5 // Delay until "alu" finshed
	 $display("Test1: opcode= %0d,  a= %0d , b= %0d , result = %0d",opcode, a, b, result);	
		
    end
	
endmodule	


///////////////////////////////////////////////////( -The register file- )///////////////////////////////////////////////////
module reg_file (clk, valid_opcode, addr1, addr2, addr3, in , out1, out2);	   
	
	input clk;
	input valid_opcode;
	input [4:0] addr1,addr2,addr3;
	input [31:0] in; 
	output reg [31:0] out1, out2;		
	
	reg [31:0] memory [0:31];  //32x32- bit words	  
	
	// Initialize memory 
	initial begin
		memory[0] = 32'd0;
		memory[1] = 32'd4616;
		memory[2] = 32'd11640; 
		memory[3] = 32'd11254; 
		memory[4] = 32'd6786; 
		memory[5] = 32'd6784; 
		memory[6] = 32'd12432; 
		memory[7] = 32'd13548;
		memory[8] = 32'd13462;
		memory[9] = 32'd13454;
		memory[10] = 32'd11780;
		memory[11] = 32'd13170;
		memory[12] = 32'd2982;
		memory[13] = 32'd8096; 
		memory[14] = 32'd514;
		memory[15] = 32'd3600;
		memory[16] = 32'd10870;
		memory[17] = 32'd12528;
		memory[18] = 32'd9860;
		memory[19] = 32'd6166;
		memory[20] = 32'd4520;
		memory[21] = 32'd14436;
		memory[22] = 32'd12136;
		memory[23] = 32'd5134;
		memory[24] = 32'd11958;
		memory[25] = 32'd7688;
		memory[26] = 32'd5258;
		memory[27] = 32'd12420;
		memory[28] = 32'd3560;
		memory[29] = 32'd1248;	
		memory[30] = 32'd8724;	
		memory[31] = 32'd0;
		
	end		   
	
	always @(posedge clk)
		begin
		if (valid_opcode) 
			begin
			out1 <= memory[addr1];
			out2 <= memory[addr2];
			memory[addr3] <= in;
		end
	end				   
	
endmodule		

module test_reg_file;  //////////////Stimulus for testing reg_file 

    // Inputs
    reg clk;
    reg valid_opcode;
    reg [4:0] addr1, addr2, addr3;
    reg [31:0] in;
    // Outputs
    wire [31:0] out1, out2;

    
    reg_file U1 (.clk(clk), .valid_opcode(valid_opcode), .addr1(addr1),.addr2(addr2), .addr3(addr3), .in(in), .out1(out1),.out2(out2));	 
	
	initial begin
    clk = 0; 
    repeat (10)	 
    #5 clk = ~clk; 
   end	
   
    initial begin
    // Initialize inputs
    valid_opcode = 1;	
	addr1 = 5'b00001;
    addr2 = 5'b00010;
    addr3 = 5'b00011;
    in = 32'd8724;
							
    // Apply stimulus
    #5 valid_opcode = 0;
    #5 valid_opcode = 1;

	 $display("Time=%0t, out1= %0d, out2= %0d", $time, out1, out2);	
	  $display("Time=%0t,in= %0d", $time,in);
    
    #100 $finish;  
	end
endmodule	

///////////////////////////////////////////////////( -The core of the microprocessor- )/////////////////////////////////////		
module mp_top (clk, instruction , result );		
	
  input clk;
  input [31:0] instruction;
  output reg [31:0] result;		
  
    reg [5:0] opcode;
    reg [4:0] addr1, addr2, addr3;
    reg valid_opcode = 6'b000000;	  
    reg [31:0] in = 32'b0;	 		
    reg [31:0] out1, out2;		
	reg [31:0] unused ;	   
	 				
	
	// Control signal to prevent "reg_file" from performing operations until registry values are valid
  reg valid_data;
	 
	 
	always @(posedge clk) 
	  begin
        opcode = instruction[5:0];
        addr1 = instruction[10:6];
        addr2 = instruction[15:11];
        addr3 = instruction[20:16];	  	
	    unused = instruction ;
		unused[31:21] = 11'b0;
		
        if ((opcode == 6'b000001) || (opcode == 6'b000010) || (opcode == 6'b000011) || (opcode == 6'b000100) || (opcode == 6'b000101)  || (opcode == 6'b000110) || (opcode == 6'b000111) || (opcode == 6'b001000) || (opcode == 6'b001011) || (opcode == 6'b001101) || (opcode == 6'b001111) )
	      begin
	       #5  valid_opcode <= opcode;	
            valid_data <= 1;	  
         end else begin
           valid_data <= 0;
		end 
			  
			   
	  end
  
    reg_file U1 (clk,valid_data,addr1, addr2, addr3 ,result, out1, out2);
     alu U2 (valid_opcode , out1, out2, result);
		  				
      
endmodule


module test_mp_top;
	
  // Inputs
  reg clk;
  reg [31:0] instruction;

  // Outputs
  wire [31:0]  result; 	 
  
  // Instantiate the mp_top module
  mp_top U1 (.clk(clk), .instruction(instruction), .result(result));   
  
  reg  [31:0] test_instructions [0:2] ;
  reg signed [31:0] expected_result [0:2] ; 
  
  reg flag = 1; 
  
  initial begin
    clk = 0;
    repeat (15)   
      #5 clk = ~clk; 
  end
  
   initial begin
  test_instructions[0] = 32'b00000000000_11111_00010_00101_000001;	   //ADD
  test_instructions[1] = 32'b00000000000_10101_01100_01110_000010;	   //XOR
  test_instructions[2] = 32'b00000000000_11110_00010_11111_001111;	  //NOT	  
  
  expected_result[0] =  32'd16256;
  expected_result[1] =  32'd1496;
  expected_result[2] =  -32'd16256;
  end			  
  
  integer i;
  initial begin
  for (i = 0; i <= 2; i=i+1) begin	   
    instruction = test_instructions[i];	 											
    #20;								
     $display("Test%0d:Time= %0t instruction= %032b, opcode= %06b, result= %0d =>  expected_result= %0d",i+1 ,$time,instruction, instruction[5:0], result ,  expected_result[i]);
	   
	   if(result !== expected_result[i])begin  
		    flag = 0;
		   	  $display("FAIL");
	   end else begin 
	   	    $display("PASS");
	   end
   
  end 
  
  // Finish simulation after all tests
     #100 $finish;
  end
 
	
endmodule	
	
	