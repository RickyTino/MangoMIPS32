module mango_lib_mux #(
    parameter NUM = 8,
    parameter type T = logic 
)
(
    input   T [NUM-1:0]     data_i,
    input     [NUM-1:0]     sel_i,
    output  T               data_o
);

    always_comb begin : g_mux
        data_o = '0;
        for (int i = 0; i < NUM; i++) begin
            data_o |= sel_i[i] ? data_i[i] : '0;
        end
    end

endmodule