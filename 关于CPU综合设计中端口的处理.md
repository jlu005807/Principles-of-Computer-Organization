# 关于CPU综合设计中端口的处理

- 阅读前提：数据通路中将移位运算放到ALU,而未放到扩展模块里，所以对于数据通路不一样的同学仅供参考
- 这是我的CPU的端口,根据单周期CPU帮手文档设计

```cpp
module m_CPU(
           input wire clk,
           input wire rst,
           input wire[31:0] base_ram_data,
           output wire[19:0] base_ram_addr,
           output wire[3:0] base_ram_be_n,
           output wire base_ram_ce_n,
           output wire base_ram_oe_n,
           output wire base_ram_we_n,
           inout wire[31:0] ext_ram_data,
           output wire[19:0] ext_ram_addr,
           output wire[3:0] ext_ram_be_n,
           output wire ext_ram_ce_n,
           output wire ext_ram_oe_n,
           output wire ext_ram_we_n
       );
```

- 对于clk和rst只要和外部相连即可
- 对于使能端

1. base_ram

```verilog
//BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
assign base_ram_be_n=4'b0000;
//BaseRAM片选，低有效，默认为有效
assign base_ram_ce_n=1'b0;
//BaseRAM读使能，低有效根据程序来看IM即base_ram只读不写，所以oe置零，we置一
assign base_ram_oe_n=1'b0;
assign base_ram_we_n=1'b1;


```



2. ext_ram

```verilog
   //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
assign ext_ram_be_n = 4'b0000;
//ExtRAM片选，低有效,当需要读存储器或者写存储器时置零，即有效
assign ext_ram_ce_n = ~(MemRead | MemWrite);
//ExtRAM读使能，低有效，当需要读存储器置零，即根据控制信号赋值
assign ext_ram_oe_n = ~MemRead;
//ExtRAM写使能，低有效，当需要写存储器时置零，同样根据控制信号
assign ext_ram_we_n = ~MemWrite;

```

这里要注意因为base_ram和ext_ram的地址只有20位，所以输入时对于三十二位的数据处理

- 对于base_ram的data直接输入到需要的位置即可，而对于addr,则因为指令存储器按字编制所以取pc[21:2]，即pc除以4后以字为单位（个人理解）

```verilog
assign ram_addr = pc[21:2];//记得传入pc[21:2],因为按字编制
```

- 对于ext_ram的地址也是如此

```verilog
assign ext_ram_addr = Address[21:2];
```

- 对于ext_ram的data则有些许麻烦了，因为ext_ram_data端口值为inout,所以需要使用三态门处理

- 这里有两种处理，但是具体对于你的CPU实现请自己代入处理
- 一是直接利用三目运算符实现三态门，例如对于 （ inout IO_data)
- 这里假设control为高电平时inout端口写入

```cpp
assign O_data_out = IO_data;//O_data_out为需要输出到的地方或者输出线
assign IO_data = (control == 1'b1) ? I_data_in : 32'bz;//I_data_in为需要写入的值或者输入线

```

- 二是创建三态门模板

```verilog
module inout_top(
    input[31:0] I_data_in,//输入线
    inout[31:0] IO_data,//inout端口
    output[31:0] O_data_out,//输出线
           input wire control//控制信号
       );

assign IO_data = (control==1'b1)? I_data_in : 32'bz;
assign O_data_out = IO_data;

endmodule

```



- 以上内容仅供参考