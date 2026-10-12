module control_unit ( 
    input wire clk,
    input wire rst,
    input wire ready,                      // ready of i2c 
    input wire [9:0] temp_in,             // Donnée d'entrée température
    input wire [9:0] humidity_in,        // Donnée d'entrée humidité
    output reg send_uart,                  // Signal de déclenchement de l'UART
    output reg [3:0] trigger_alarm,       // bit0=TempLow, bit1=TempHigh, bit2=HumLow, bit3=HumHigh
    output reg alerte,                     // 1 = normale, 0 = alerte
    output reg [9:0] temp_out,        // Donnée envoyée vers UART
   // output reg [9:0] temp_to_interface, 
    // output reg [15:0] humidity_to_interface, // Donnée vers interface utilisateur
    output reg [9:0] humidity_out,
    output reg start2,                        // start for i2c
    output reg start                        // start for i2c
);

    // Seuils de température et humidité
    localparam [9:0]  LOW_THRESHOLD_T  = 10'd170;  // 17.0°C
    localparam [9:0]  HIGH_THRESHOLD_T = 10'd270;  // 27.0°C
    localparam [9:0] LOW_THRESHOLD_H  = 16'd60;  // 60%
    localparam [9:0] HIGH_THRESHOLD_H = 16'd90;  // 90%
    parameter integer T_CONV = 10;

    // Registres internes
    reg [25:0] timer;
    reg phase;
    reg first_start;

    // --- Logique séquentielle pour timer/start/I2C ---
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            send_uart <= 0;
            trigger_alarm <= 4'b0000;
            alerte <= 0;
            temp_out <= 10'd0;
           // temp_to_interface <= 10'd0;
            //humidity_to_interface <= 16'd0;
            humidity_out <= 16'd0;
            start <= 0;
            timer <= 0;
            phase <= 0;
            first_start <= 1;
        end else begin
            send_uart <= 0;
            start <= 0;
            start2 <= 0;
            // impulsion de démarrage I2C
            if (first_start) begin
                start2 <= 1;
                first_start <= 0;
            end

            // Gestion du timer pour I2C
            if (phase == 0) begin
                if (ready) begin
                    timer <= 0;
                    phase <= 1;
                end
            end else begin
                if (timer == T_CONV) begin
                    start <= 1;
                    phase <= 0;
                end else begin
                    timer <= timer + 1;
                end
            end
        end
    end

    // --- Logique combinatoire pour les alertes ---
    always @(*) begin
        trigger_alarm = 4'b0000; // Par défaut aucune alerte
        temp_out = 10'd0;
        humidity_out = 16'd0;

        // Température
        if (temp_in < LOW_THRESHOLD_T) begin
            trigger_alarm[0] = 1'b1;  // Temp basse
            temp_out = temp_in;
        end else if (temp_in > HIGH_THRESHOLD_T) begin
            trigger_alarm[1] = 1'b1;  // Temp haute
            temp_out = temp_in;
        end

        // Humidité
        if (humidity_in < LOW_THRESHOLD_H) begin
            trigger_alarm[2] = 1'b1;  // Humidité basse
            humidity_out = humidity_in;
        end else if (humidity_in > HIGH_THRESHOLD_H) begin
            trigger_alarm[3] = 1'b1;  // Humidité haute
            humidity_out = humidity_in;
        end

        // Envoi UART si une alerte existe
        send_uart = (trigger_alarm != 4'b0000) ? 1'b1 : 1'b0;

        // Etat alerte général
        alerte = (trigger_alarm == 4'b0000) ? 1'b0 : 1'b1;

        // Sortie vers interface utilisateur
        //temp_to_interface = temp_in;
       // humidity_to_interface = humidity_in;
    end

endmodule
