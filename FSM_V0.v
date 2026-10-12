`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.06.2025 12:08:00
// Design Name: 
// Module Name: control_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// Déclaration du module avec ses entrées/sorties
module control_unit (
    input  wire        clk,              // Horloge du système
    input  wire        reset,            // Remise à zéro
    input  wire        adc_done,         // Signal : ADC terminé
    input  wire        temp_done,        // Signal : conversion température terminée
    input  wire        uart_done,        // Signal : transmission UART terminée
    input  wire [7:0]  temperature,      // Température convertie (8 bits)

    output reg         start_adc,        // Démarrer l'ADC
    output reg         write_enable,     // Écriture dans le buffer
    output reg         uart_enable,      // Transmission UART
    output reg         alert_enable      // Alerte utilisateur
);

// Définition du seuil
parameter [7:0] THRESHOLD = 8'd38;

// Définition des états (codés manuellement)
parameter IDLE         = 3'd0;
parameter START_ADC    = 3'd1;
parameter WAIT_ADC     = 3'd2;
parameter WRITE_BUFFER = 3'd3;
parameter COMPARE      = 3'd4;
parameter SEND_UART    = 3'd5;
parameter ALERT_USER   = 3'd6;

// Registres pour stocker les états
reg [2:0] current_state, next_state;

// === Partie séquentielle : changer d'état sur front d'horloge ===
always @(posedge clk or posedge reset) begin
    if (reset)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

// === Partie combinatoire : logique de transition d'état ===
always @(*) begin
    // Valeur par défaut
    next_state = current_state;

    case (current_state)
        IDLE: begin
            next_state = START_ADC;
        end

        START_ADC: begin
            if (adc_done)
                next_state = WAIT_ADC;
        end

        WAIT_ADC: begin
            if (temp_done)
                next_state = WRITE_BUFFER;
        end

        WRITE_BUFFER: begin
            next_state = COMPARE;
        end

        COMPARE: begin
            next_state = SEND_UART;
        end

        SEND_UART: begin
            if (uart_done) begin
                if (temperature >= THRESHOLD)
                    next_state = ALERT_USER;
                else
                    next_state = IDLE;
            end
        end

        ALERT_USER: begin
            next_state = IDLE;
        end
    endcase
end

// === Logique des sorties ===
always @(*) begin
    // Valeurs par défaut
    start_adc     = 0;
    write_enable  = 0;
    uart_enable   = 0;
    alert_enable  = 0;

    case (current_state)
        START_ADC: begin
            start_adc = 1;
        end

        WRITE_BUFFER: begin
            write_enable = 1;
        end

        SEND_UART: begin
            uart_enable = 1;
        end

        ALERT_USER: begin
            alert_enable = 1;
        end
    endcase
end

endmodule

