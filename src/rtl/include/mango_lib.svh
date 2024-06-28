`ifndef MANGO_LIB_SVH
`define MANGO_LIB_SVH

// flipflops
`ifdef MANGO_CFG_SIM_XPROP
    `define DFFPNNN(clk, d, q) \
        always_ff @(posedge clk) begin \
            q <= d; \
        end

    `define DFFPNNE(clk, e, d, q) \
        always_ff @(posedge clk) begin \
            if(e)       q <= d; \
            else if(~e) q <= q; \
            else        q <= 'x; \
        end

    `define DFFPANN(clk, rst, rst_val, d, q) \
        always_ff @(posedge clk, negedge rst) begin \
            if(~rst)     q <= rst_val; \
            else if(rst) q <= d;
            else         q <= 'x; \
        end

    `define DFFPANE(clk, rst, rst_val, e, d, q) \
        always_ff @(posedge clk, negedge rst) begin \
            if(~rst)        q <= rst_val; \
            else if(rst) \
                if(e)       q <= d; \
                else if(~e) q <= q; \
                else        q <= 'x; \
            else            q <= 'x; \
        end
`else
    `define DFFPNNN(clk, d, q) \
        always_ff @(posedge clk) begin \
            q <= d; \
        end

    `define DFFPNNE(clk, e, d, q) \
        always_ff @(posedge clk) begin \
            if(e) q <= d; \
        end

    `define DFFPANN(clk, rst, rst_val, d, q) \
        always_ff @(posedge clk, negedge rst) begin \
            if(~rst) q <= rst_val; \
            else     q <= d; \
        end

    `define DFFPANE(clk, rst, rst_val, e, d, q) \
        always_ff @(posedge clk, negedge rst) begin \
            if(~rst)   q <= rst_val; \
            else if(e) q <= d; \
        end
`endif

// encode / decode

`define ENCODE(i_a, o_a) \
    always_comb begin \
        o_a = 1 << $clog2($size(i_a)); \
        for (int __idx = $low(i_a); __idx < $high(i_a); __idx++) \
            o_a |= i_a[__idx] ? __idx : '0; \
    end 

`define DECODE(i_a, o_a) \
    always_comb begin \
        for (int __idx = $low(o_a); __idx < $high(o_a); __idx++) \
            o_a[__idx] = (i_a == __idx) ? 1'b1 : 1'b0; \
    end 

`define VLD_DECODE(vld, i_a, o_a) \
    always_comb begin \
        for (int __idx = $low(o_a); __idx < $high(o_a); __idx++) \
            o_a[__idx] = (vld) & (i_a == __idx) ? 1'b1 : 1'b0; \
    end 

`define MUX_1H(i_a, i_b, o_a) \
    always_comb begin \
        for (int __idx = $low(i_a); __idx < $high(i_a); __idx++) \
            o_a |= i_a[__idx] ? i_b[__idx] : '0; \
    end

`endif // MANGO_LIB_SVH