`timescale 1ns / 1ps

`include "sabitler.vh"

module matris_carpici (
    input   clk_g,
    input   resetn,

    input [`ADRES_BIT-1:0]      at_boyut_g,
    input [`ADRES_BIT-1:0]      at_adres1_g,
    input [`ADRES_BIT-1:0]      at_adres2_g,
    input                       at_gecerli_g,     
    input [`ADRES_BIT-1:0]      at_adres_sonuc_g, // ?? bune
    output                      at_mesgul_c,

    output [`ADRES_BIT-1:0]     ram_adres_c,
    output                      ram_oku_gecerli_c,
    input  [`VO_VERI_BIT-1:0]   ram_oku_veri_g,
    input  [`ADRES_BIT-1:0]     ram_oku_adres_g, 
    input                       ram_oku_gecerli_g,                  
    output [`VO_VERI_BIT-1:0]   ram_yaz_veri_c,     
    output                      ram_yaz_gecerli_c,
    input                       ram_mesgul_g


);

localparam
BEKLE       = 'd1,
VERI_OKU    = 'd2,
ISLEM       = 'd4,
SONUCU_YAZ  = 'd8;

reg [3:0]   state, state_next;

reg [`ADRES_BIT-1:0]    sonuc_sutun_r, sonuc_sutun_next_r; // Sonuc matrisi indexini tutan yazmac 
reg [`ADRES_BIT-1:0]    sonuc_satir_r, sonuc_satir_next_r; // Sonuc matrisi indexini tutan yazmac 
reg [`ADRES_BIT-1:0]    sonuc_sayaci_r, sonuc_sayaci_next_r;
reg [`ADRES_BIT-1:0]    okuma_sayaci_r, okuma_sayaci_next_r;


reg [`ADRES_BIT-1:0]    boyut_r, boyut_next_r; 
reg [`ADRES_BIT-1:0]    adres1_r, adres1_next_r;
reg [`ADRES_BIT-1:0]    adres2_r, adres2_next_r;
reg [`ADRES_BIT-1:0]    sonuc_ptr_r, sonuc_ptr_next_r;


reg [`ADRES_BIT-1:0]    adres_sonuc_r, adres_sonuc_next_r;

reg [`VO_VERI_BIT-1:0]  sonuc_r, sonuc_next_r;

reg [`VO_VERI_BIT-1:0]  veri_satiri1_r, veri_satiri1_next_r; // Bellekten gelen veri satiri
reg [`VO_VERI_BIT-1:0]  veri_satiri2_r, veri_satiri2_next_r; // 

reg [`ADRES_BIT-1:0]    satir1_adresi_r, satir1_adresi_next_r; 
reg [`ADRES_BIT-1:0]    satir2_adresi_r, satir2_adresi_next_r;

reg                     dizi1_gecerli_r, dizi1_gecerli_next_r;
reg                     dizi2_gecerli_r, dizi2_gecerli_next_r;

reg                     oku_r, oku_next_r;

reg                     veri_oku_flag_r, veri_oku_flag_next_r;
reg                     sonucu_yaz_r, sonucu_yaz_next_r;

reg [`ADRES_BIT-1:0]    matris_sayaci_r, matris_sayaci_next_r;

wire                    mesgul_w;

wire [`ADRES_BIT-1:0]   matris1_satir_adresi_w;
wire [`ADRES_BIT-1:0]   matris2_satir_adresi_w;
wire [`ADRES_BIT-1:0]   sonuc_satir_adresi_w;

wire                    satir1_gecerli_w;
wire                    satir2_gecerli_w;

wire [`ADRES_BIT-1:0]   index1_w;
wire [`ADRES_BIT-1:0]   index2_w;
wire [`ADRES_BIT-1:0]   index_sonuc_w;

assign  mesgul_w = state != BEKLE;

assign  ram_oku_gecerli_c = oku_r;

assign  index1_w = ((boyut_r*sonuc_satir_r+sonuc_sayaci_r[1:0])<<5);
assign  index2_w = ((sonuc_sutun_r+boyut_r*sonuc_sayaci_r[1:0])<<5);
assign  index_sonuc_w = okuma_sayaci_r<<6;

assign  sonuc_satir_adresi_w = sonuc_ptr_r+((sonuc_sutun_r+boyut_r*sonuc_satir_r)<<6);

assign  matris1_satir_adresi_w = adres1_r+((boyut_r*sonuc_satir_r+sonuc_sayaci_r)<<5); // Carpilan indisin bulundugu satir adresi

assign  matris2_satir_adresi_w = adres2_r+((sonuc_sutun_r+boyut_r*sonuc_sayaci_r)<<5);

// assign  son bitleri parametrik olarak yok say  
// assign  


assign  ram_adres_c = sonucu_yaz_r ? sonuc_satir_adresi_w : (dizi1_gecerli_r ? matris2_satir_adresi_w : matris1_satir_adresi_w);

assign  ram_yaz_gecerli_c = sonucu_yaz_r;

assign  ram_yaz_veri_c = sonuc_r;

assign  satir1_gecerli_w = satir1_adresi_r[31:7]==matris1_satir_adresi_w[31:7];
assign  satir2_gecerli_w = satir2_adresi_r[31:7]==matris2_satir_adresi_w[31:7];

always@* begin
    state_next = state;
    boyut_next_r = boyut_r;
    adres1_next_r = adres1_r;
    adres2_next_r = adres2_r;
    adres_sonuc_next_r = adres_sonuc_r;

    oku_next_r = 1'b0;
    sonuc_next_r = sonuc_r;
    
    sonucu_yaz_next_r = 1'b0;

    sonuc_sutun_next_r = sonuc_sutun_r;
    sonuc_satir_next_r = sonuc_satir_r;
    sonuc_sayaci_next_r = sonuc_sayaci_r;
    okuma_sayaci_next_r = okuma_sayaci_r;

    veri_satiri1_next_r = veri_satiri1_r;     
    veri_satiri2_next_r = veri_satiri2_r; 

    satir1_adresi_next_r = satir1_adresi_r; 
    satir2_adresi_next_r = satir2_adresi_r; 

    dizi1_gecerli_next_r = dizi1_gecerli_r;
    dizi2_gecerli_next_r = dizi2_gecerli_r;

    veri_oku_flag_next_r = veri_oku_flag_r;
    sonucu_yaz_next_r = 1'b0;

    matris_sayaci_next_r = matris_sayaci_r;

    sonuc_ptr_next_r = sonuc_ptr_r;

    case(state)
    
    BEKLE: begin
        if(~mesgul_w && at_gecerli_g) begin
            state_next  = VERI_OKU;
            
            dizi1_gecerli_next_r = 1'b0;
            dizi2_gecerli_next_r = 1'b0;
            veri_oku_flag_next_r = 1'b1;

            boyut_next_r        = at_boyut_g;
            adres1_next_r       = at_adres1_g;
            adres2_next_r       = at_adres2_g;
            adres_sonuc_next_r  = at_adres_sonuc_g;

            sonuc_ptr_next_r    = at_adres_sonuc_g;

            sonuc_satir_next_r = 'd0;
            sonuc_sutun_next_r = 'd0;
            sonuc_sayaci_next_r = 'd0;
            okuma_sayaci_next_r = 'd0;
        end
    end

    VERI_OKU: begin
        if(veri_oku_flag_r) begin
            veri_oku_flag_next_r = 1'b0;
            oku_next_r = 1'b1;
        end
        else if(ram_oku_gecerli_g) begin
            veri_oku_flag_next_r    = dizi1_gecerli_r ? 1'b0 : 1'b1;

            veri_satiri1_next_r     = dizi1_gecerli_r ? veri_satiri1_r : ram_oku_veri_g;
            veri_satiri2_next_r     = dizi1_gecerli_r ? ram_oku_veri_g  : 'b0;

            satir1_adresi_next_r    = dizi1_gecerli_r ? satir1_adresi_r : ram_oku_adres_g;
            satir2_adresi_next_r    = dizi1_gecerli_r ? ram_oku_adres_g : 'b0;

            dizi1_gecerli_next_r    = 1'b1;
            dizi2_gecerli_next_r    = dizi1_gecerli_r ? 1'b1 : 1'b0;
        end
        else if(dizi1_gecerli_r && dizi2_gecerli_r) begin    
            state_next  = ISLEM;
        end            
    end

    ISLEM: begin
        if((sonuc_satir_r < boyut_r)&&(sonuc_sutun_r < boyut_r)) begin
            if(sonuc_satir_adresi_w[31:7]==adres_sonuc_r[31:7]) begin
                if(sonuc_sayaci_r < boyut_r) begin
                    sonuc_next_r[index_sonuc_w+:2*`ADRES_BIT] = sonuc_r[index_sonuc_w+:2*`ADRES_BIT] + veri_satiri1_r[index1_w+:`ADRES_BIT]*veri_satiri2_r[index2_w+:`ADRES_BIT];
                    sonuc_sayaci_next_r = sonuc_sayaci_r + 'd1;
                end
                else begin
                    okuma_sayaci_next_r = okuma_sayaci_r  + 'd1;
                    if(sonuc_sutun_r < boyut_r-1) begin
                        sonuc_sutun_next_r = sonuc_sutun_r + 'd1;
                        sonuc_sayaci_next_r = 'd0;
                    end
                    else if(sonuc_satir_r < boyut_r-1) begin
                        sonuc_satir_next_r = sonuc_satir_r + 'd1;
                        sonuc_sutun_next_r = 'd0;
                        sonuc_sayaci_next_r = 'd0;
                    end
                end
            end
            else begin
                state_next = SONUCU_YAZ;
            end
        end
        else begin
            state_next = SONUCU_YAZ;
        end
    end

    SONUCU_YAZ: begin
        if((sonuc_sutun_r < boyut_r) && (sonuc_satir_r < boyut_r)) begin
            sonucu_yaz_next_r = 1'b1;
            adres_sonuc_next_r = adres_sonuc_r + `VO_VERI_BIT;
            state_next = ISLEM;
            sonuc_next_r = 'd0;
            okuma_sayaci_next_r = 'd0;
        end
        else begin
            state_next = BEKLE;
        end
    end
    endcase


end

always@(posedge clk_g) begin
    if(resetn) begin
        state <= BEKLE;
        boyut_r <= 0;
        adres1_r <= 0;
        adres2_r <= 0;
        adres_sonuc_r <= 0;
        oku_r <= 0;
        sonuc_r <= 0;
        sonucu_yaz_r <= 0;
        veri_oku_flag_r <= 0;
        sonuc_sutun_r <= 0;
        sonuc_satir_r <= 0;
        sonuc_sayaci_r <= 0;
        okuma_sayaci_r <= 0;
        veri_satiri1_r <= 0;   
        veri_satiri2_r <= 0; 
        satir1_adresi_r <= 0; 
        satir2_adresi_r <= 0; 
        dizi1_gecerli_r <= 0;
        dizi2_gecerli_r <= 0;
        matris_sayaci_r <= 0;
        sonuc_ptr_r <= 0;
    end
    else begin
        state <= state_next;
        boyut_r <= boyut_next_r;
        adres1_r <= adres1_next_r;
        adres2_r <= adres2_next_r;
        adres_sonuc_r <= adres_sonuc_next_r;
        oku_r <= oku_next_r;
        sonuc_r <= sonuc_next_r;
        sonucu_yaz_r <= sonucu_yaz_next_r;
        veri_oku_flag_r <= veri_oku_flag_next_r;
        sonuc_sutun_r <= sonuc_sutun_next_r;
        sonuc_satir_r <= sonuc_satir_next_r;
        sonuc_sayaci_r <= sonuc_sayaci_next_r;
        okuma_sayaci_r <= okuma_sayaci_next_r;
        veri_satiri1_r <= veri_satiri1_next_r;   
        veri_satiri2_r <= veri_satiri2_next_r; 
        satir1_adresi_r <= satir1_adresi_next_r; 
        satir2_adresi_r <= satir2_adresi_next_r; 
        dizi1_gecerli_r <= dizi1_gecerli_next_r;
        dizi2_gecerli_r <= dizi2_gecerli_next_r;
        matris_sayaci_r <= matris_sayaci_next_r;
        sonuc_ptr_r <= sonuc_ptr_next_r;
    end
end

endmodule

