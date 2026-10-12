`timescale 1ns/1ps

module control_unit_tb;

    // =========================
    // Entrées
    // =========================
    reg clk;
    reg rst;
    reg ready;
    reg [9:0]  temp_in;
    reg [9:0] humidity_in;

    // =========================
    // Sorties
    // =========================
    wire send_uart;
    wire [3:0] trigger_alarm;   // 4 bits maintenant
    wire alerte;
    wire [9:0]  temp_out;
    //wire [9:0]  temp_to_interface;
    //wire [15:0] humidity_to_interface;
    wire [9:0] humidity_out;
    wire start;

    // =========================
    // DUT
    // =========================
    control_unit dut (
        .clk(clk),
        .rst(rst),
        .ready(ready),
        .temp_in(temp_in),
        .humidity_in(humidity_in),
        .send_uart(send_uart),
        .trigger_alarm(trigger_alarm),
        .alerte(alerte),
        .temp_out(temp_out),
        //.temp_to_interface(temp_to_interface),
        //.humidity_to_interface(humidity_to_interface),
        .humidity_out(humidity_out),
        .start(start)
    );

    // =========================
    // Horloge 10 ns
    // =========================
    always #5 clk = ~clk;


// =========================
// Observer start
// =========================
always @(posedge start) begin
    $display("Start generated at time = %0t ns", $time);
end
    // =========================
    // Stimulus
    // =========================
    initial begin
        $display("===== START SIMULATION =====");
        $dumpfile("control_unit_tb.vcd");
        $dumpvars(0, control_unit_tb);

        // Init
        clk = 0;
        rst = 1;
        ready = 0;
        temp_in = 10'd0;
        humidity_in = 16'd0;

        #12;
        rst = 0;
        ready = 1;  // ready activé pour I2C

        // -------------------------
        // Cas 1 : normal
        // -------------------------
        temp_in = 10'd220;      // 22.0 °C
        humidity_in = 16'd65;  // 65 %
        #20;

        // -------------------------
        // Cas 2 : température basse
        // -------------------------
        temp_in = 10'd150;      // 15.0 °C
        humidity_in = 16'd65;
        #20;

        // -------------------------
        // Cas 3 : température haute
        // -------------------------
        temp_in = 10'd280;      // 28.0 °C
        humidity_in = 16'd65;
        #20;

        // -------------------------
        // Cas 4 : humidité basse
        // -------------------------
        temp_in = 10'd220;
        humidity_in = 16'd50;  // 50 %
        #20;

        // -------------------------
        // Cas 5 : humidité haute
        // -------------------------
        temp_in = 10'd220;
        humidity_in = 16'd95;  // 95 %
        #20;

        // -------------------------
        // Cas 6 : double alerte
        // -------------------------
        temp_in = 10'd280;
        humidity_in = 16'd95;
        #20;

        // -------------------------
        // Cas 7 : retour normal
        // -------------------------
        temp_in = 10'd220;
        humidity_in = 16'd65;
        #20;

        $display("===== END SIMULATION =====");
        $finish;
    end

endmodule
