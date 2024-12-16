# CPU综合设计小错误

- 一是一些拼写问题，导致有些变量未声明

```verilog
wire mdataout;
assign wdataout= //.....
```

- 上述例子中vivado不报错，并且可以生成波形图



- 二是对于数据位宽问题，导致对于数据处理出现溢出

```verilog
//例子一
wire[32:0] pc;
wire pcplus4;
pcplus4=pc+4;
//这里会导致pc一直初始化后一直是全零

//例子二，将32位数据传给20位的地址
assign ext_ram_addr = alu_result;
```

- 三是bin文件下载错误，应该下载MIPS赛道的bin文件并且注意文件路径写法，具体操作详见帮手文件

- 四是传入base_ram_addr的pc截取的部分

```verilog
//错误
assign base_ram_addr = pc[19:0];
///正确
assign base_ram_addr = pc[21:2];
```



- 五是对于zero的处理，是alu_result为1时zero为0，还是alu_result为0时zero为0，以至于对跳转指令的操作有误



- 六是对于使能端运算错误

```verilog
assign ext_ram_ce_n = ext_ram_on_n | ext_ram_we_n;

//正确最好使用控制信号
assign ext_ram_ce_n = ~(Memread | Memwrite);
```





