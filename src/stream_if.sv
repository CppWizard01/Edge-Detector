interface stream_if #(parameter int WIDTH = 8);
    logic valid;
    logic [WIDTH-1:0] pixel;

    modport rx (
        input valid, pixel
    );

    modport tx(
        output valid, pixel
    );
endinterface