module testbench_arbiter 
 #(parameter int REQS  = 4); // The number of requests (4 is enough) // Change to 1, 2, 4 to insert bug. (0 no bug))
 //Input-Output List
 logic clk;
 logic rst;
 logic[REQS-1:0] request;
 logic[REQS-1:0] temp;   // The requests to choose from
 logic[REQS-1:0] grants_o;   // The winner (if any)
 logic  any_grant_o; // Signals that there is at least one winner
 
 //arbiter module connection
 rr_arbiter_buggy myarb(
 .clk (clk),
 .rst (rst),
 .reqs_i (request),
 .grants_o (grants_o),
 .any_grant_o (any_grant_o));
 
 //clock setup
 always begin
   clk=1;
   #10ns;
   clk=0;
   #10ns;
 end
 
 //TEST CODE
 initial begin
   $display("Started Test..");
   rst<=1;
   @(posedge clk);
   rst<=0;
   request<=4'b0000; //any grant must be zero
   @(posedge clk);
   @(posedge clk);
   request<=4'b1111;
   repeat(8)begin
     @(posedge clk); //should cycle /round robin
   end
   @(posedge clk);
   request<=4'b0101;
   repeat(8)begin
     @(posedge clk); //should cycle /round robin
   end
   rst<=1;
   request<=4'b1010;  //after reset priority to zero
   @(posedge clk);
   rst<=0;
   request<=4'b1100;   //should be 2
   @(posedge clk);
   request<=4'b1000;   //should be 3
   @(posedge clk);
   request<=4'b1000;
   @(posedge clk);
   request<=4'b1100;
   @(posedge clk);
   request<=4'b0100;
   @(posedge clk);
   request<=4'b0011;
   @(posedge clk);
   repeat(8)begin
     @(posedge clk); //should cycle /round robin
   end
   request<=4'b0101;
   @(posedge clk);
   request<=4'b1100;
   @(posedge clk);
   request<=4'b1100;
   @(posedge clk);
   request<=4'b0111;
   @(posedge clk);
   request<=4'b0111;
   @(posedge clk);
   request<=4'b1001;   //should be 3
   @(posedge clk);
   request<=4'b0011;   //should be 0
   @(posedge clk);
   request<=4'b0110;   //should be 1
   @(posedge clk);

   $strobe("@%0t: grsnts_o-> %b", $time, grants_o);

   $display("Finished");
 end
 //assign regs_i=temp;
endmodule

//BUG=1 PROBLEM: When #2 requests a grant and should be given one, we get a ZERO GRANT
//BUG=2 PROBLEM: When #3,#0 requests a grant, any_grant becomes Zero, and the cycle stops and remains there as long as #3 request is up
//BUG=4 PROBLEM: When #3 SHOULD be given a grant, it gives grant to #3 AND #4
//BUG=8 PROBLEM: When #4 is up ,cycle works until it gives grant to #4 and then it stays there(at #4)...when #4 is down, cycle freezes