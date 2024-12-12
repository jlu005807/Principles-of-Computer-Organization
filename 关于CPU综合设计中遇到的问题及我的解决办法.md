# 关于CPU综合设计中遇到的问题及我的解决办法

- 首先仿真时，我发现自己的base_ram_data和base_ram_addr一直为不确定态
- 然后我发现对于传进来的rst信号没有使用，所以我接着采用rst将在pc模块里base_ram_addr初始化为全零

```verilog
module PC(
    input wire rst,
    //.......端口不完整
    output wire [19:0] ram_addr
    );
    always @(*) begin
    if(rst)
        ram_addr=20'b0;
    else 
        ram_addr=pc[21:0];
end
//其他内容省略......
endmodule
```

- 初始化后发现base_ram_data读进来了，但是base_ram_addr一直为全零没有变化，紧接着发现pc一直为全零没有变化，所以尝试加入时序到PC(这里不清楚为什么)

```verilog
module PC(
    input wire rst,
    input wire clk,
    //.......端口不完整
    output wire [19:0] ram_addr
    );
    always @(posedge clk) begin
    if(rst)
        ram_addr=20'b0;
    else 
        ram_addr=pc[21:0];
end
//其他内容省略......
endmodule
```

- 然后发现PC可以正常变化了，并且**建议尽量只在PC模板里或者一个位置更新PC即对新旧PC的处理**

- 但是发现我的PC会一直在跳转指令循环不动了
- 然后重新理清一遍数据通路修改了一些逻辑错误就跑通了，所以最重要的是**数据通路没有错再去考虑时序问题会简单一点**



- 对于中间过程的分析，因为仿真只能看到thinpad_top.v端口的波形，所以可以在你的CPU.v里间断输出一些变量值以供在vivado的终端里查看和分析

- 例如：仅供参考，不同时序可能导致PC和对应的指令不同，请根据自己需要输出变量到终端

```verilog
always @(PC) begin
    $display("i:%d",i);//第几个指令，从零开始
    i=i+1;
    $display("PC:%h,instruction:%h",PC_out,instruction);
    $display("instruction[31:26]:%b,rs:%b,rt:%b,rd:%b,func:%b,imm:%b",instruction[31:26],instruction[25:21],instruction[20:16],write_register,instruction[5:0],instruction[15:0]);
    $display("read_data1:%h,read_data2:%h,reg_write_data:%h,dm_read_data:%h",read_data1,read_data2,reg_write_data,dm_read_data);
    $display("ALU_op1:%h,ALU_op2:%h,ALU_result:%h,zero:%h,PCsrc:%b,Memtoreg:%b,bne_addr:%h\n",ALU_op1,ALU_op2,ALU_result,zero,PCsrc,MemtoReg,bne_addr);
end
```



- 这里想到仿真可能发现你的数据一直不变，可能是因为时钟频率过低，导致一段时间的仿真无法看出变化
- 所以这里有两种处理办法

1. 最直接的办法就是增加仿真时间，即在仿真时点击菜单栏的run for 10us功能键，即下图的蓝色圈的按钮。

   但是建议不要按太多次，容易使电脑死机（本人试过）,一般如果时钟频率为5M的话在20us左右就可以看到变化了

![](D:\Internt_of_Thing\e_book\计算机组成原理\note\assets\屏幕截图 2024-12-12 135218.png)

2. 二是增加时钟频率，但是依旧需要上述操作，并且在没跑通程序之前不建议增加时钟频率