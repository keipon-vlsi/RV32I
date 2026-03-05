`timescale 1ns / 1ps

module tb_top;

    // --- 1. 信号宣言 ---
    logic clk;
    logic reset;
    
    logic [31:0] write_data_obs;
    logic [31:0] data_address_obs;
    logic write_enable_obs;

    // --- 2. DUT (Device Under Test) のインスタンス化 ---
    top u_top (
        .clk(clk),
        .reset(reset),
        .write_data(write_data_obs),
        .data_address(data_address_obs),
        .write_enable(write_enable_obs)
    );

    // --- 3. クロック生成 ---
    always #5 clk = ~clk;

    // --- 4. 命令メモリの読み込み ---
    initial begin
        // テストしたいHexファイル名に書き換えてください（例: all_test.hex）
        $readmemh("all_test.hex", u_top.imem.instruction); 
    end

    // --- 5. データムーブメント・モニタ (Tracer) ---
    // レジスタやメモリへの書き込みを毎クロック監視し、変化があった時だけログを出力します。
    // ※内部配列名に依存しないため、Unable to bindエラーは起きません！
    
    logic [31:0] pc_obs;
    logic [31:0] instr_obs;
    logic        reg_we_obs;
    logic [4:0]  rd_addr_obs;
    logic [31:0] reg_wdata_obs;

    // ProcessorCore内部の信号をアサイン
    assign pc_obs        = u_top.PrCore.PC;
    assign instr_obs     = u_top.PrCore.instruction;
    assign reg_we_obs    = u_top.PrCore.reg_write_enable;
    assign rd_addr_obs   = instr_obs[11:7]; // rd
    assign reg_wdata_obs = u_top.PrCore.reg_data;

    always @(negedge clk) begin
        if (!reset) begin
            // レジスタへの書き込み監視 (x0 への書き込みは無視)
            if (reg_we_obs && rd_addr_obs != 5'd0) begin
                $display("Time: %0t | PC: %h | Instr: %h | REG WRITE: x%0d <= %h", 
                         $time, pc_obs, instr_obs, rd_addr_obs, reg_wdata_obs);
            end
            
            // データメモリへの書き込み監視
            if (write_enable_obs) begin
                $display("Time: %0t | PC: %h | Instr: %h | MEM WRITE: Addr[%h] <= %h", 
                         $time, pc_obs, instr_obs, data_address_obs, write_data_obs);
            end
        end
    end

    // --- 6. メインテストシーケンス ---
    initial begin
        clk = 0;
        reset = 1;
        #20;
        reset = 0;

        $display("==================================================");
        $display(" Starting RV32I Full Instruction Verification");
        $display("==================================================");

        // プログラムの終了検知 (例: 無限ループ beq x0, x0, 0 を検知)
        // ※ PC が変化しなくなったら終了とみなす
        begin : check_loop
                    forever begin
                        @(posedge clk);
                        if (u_top.PrCore.PC === u_top.PrCore.pc_next) begin
                            $display("\n[INFO] End of program detected (Infinite Loop).");
                            disable check_loop; // 指定した名前のブロックから強制的に抜ける（breakと同じ動作）
                        end
                    end
                end

        #10; // 最後の書き込みを待つ
        
        // --- 7. 最終レジスタ・ダンプ ---
        // テスト終了時に、x1 から x31 までの最終結果を一覧表示します。
        // ここで期待値と見比べることで、全命令が正しく動いたか一目で確認できます。
        $display("==================================================");
        $display(" Final Register State Dump");
        $display("==================================================");
        
        // ※ここは手動で内部配列を覗く必要があります。
        // u_top.PrCore.regfile の下の配列名を、ご自身の環境（mem, regs, registers など）に合わせてください。
        // どうしてもエラーになる場合は、この for ループ部分だけコメントアウトしてください。
        for (int i = 1; i < 32; i++) begin
            // ▼▼▼ 注: 'registers' を正しい名前に書き換えてください ▼▼▼
            $display(" x%0d \t: %h", i, u_top.PrCore.regfile.register[i]);
        end
        $display("==================================================");

        $finish;
    end

    // --- タイムアウト ---
    initial begin
        #50000; // テストが巨大な場合はこの数値を増やしてください
        $display("\n[TIMEOUT] Simulation time limit exceeded.");
        $finish;
    end

    // --- 波形出力 ---
    initial begin
        $dumpfile("rv32i_full.vcd");
        $dumpvars(0, tb_top);
    end

endmodule