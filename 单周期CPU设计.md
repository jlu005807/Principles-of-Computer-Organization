# 单周期CPU设计

[TOC]



## 目标

设计一个单周期**32位**[MIPS](D:\Internt_of_Thing\e_book\计算机组成原理\A03_“系统能力培养大赛”MIPS指令系统规范_v1.00.pdf) CPU，依据给定过的指令集，设计核心的控制信号。依据给定的数据通路和控制单元信号进行设计。

### 指令集

实现7条指令子集：**ori，lui，addu，sub，bne，lw，sw**，假设不会溢出

### 指令的类型

**R型**： addu, sub（opcode为0）

**I型**：ori,lui,lw,sw, bne

#### ori

将rs的值与0扩展为32位的立即数按位或，并将结果**写入寄存器rt**中

![image-20241127093819883](D:\Internt_of_Thing\e_book\计算机组成原理\note\assets\image-20241127093819883.png)

#### lui

将立即数**写到rt**高十六位，低十六位置零

![image-20241127093958305](D:\Internt_of_Thing\e_book\计算机组成原理\note\assets\image-20241127093958305.png)

#### addu

将寄存器rs的值与寄存器rt的值相加，结果写入rd寄存器中。

![image-20241127094346053](D:\Internt_of_Thing\e_book\计算机组成原理\note\assets\image-20241127094346053.png)

#### sub

将寄存器rs的值与寄存器rt的值相减，结果写入rd寄存器中。

![image-20241127100011592](D:\Internt_of_Thing\e_book\计算机组成原理\note\assets\image-20241127100011592.png)

#### bne

如果寄存器rs的值**不等于**寄存器rt的值则转移，否则顺序执行。转移目标由立即数offset**左移2位**并进行有符号扩展的值加上该分支指令对应的**延迟槽指令的PC**（即PC已经+4）计算得到。

![image-20241127100051566](D:\Internt_of_Thing\e_book\计算机组成原理\note\assets\image-20241127100051566.png)

![image-20241127100119281](D:\Internt_of_Thing\e_book\计算机组成原理\note\assets\image-20241127100119281.png)

#### lw

将base寄存器的值加上符号扩展后的立即数offset得到访存的虚地址，如果地址不是4的整数倍 则触发地址错例外，否则据此虚地址从存储器中读取**连续4个字节**的值，写入到rt寄存器中。

![image-20241127100408223](D:\Internt_of_Thing\e_book\计算机组成原理\note\assets\image-20241127100408223.png)

#### sw

将base寄存器的值加上符号扩展后的立即数offset得到访存的虚地址，如果地址不是4的整数倍 则触发地址错例外，否则据此虚地址将rt寄存器**存入存储器**中。

![image-20241127100510974](D:\Internt_of_Thing\e_book\计算机组成原理\note\assets\image-20241127100510974.png)

## 设计数据通路

### 思路

- 依据流水线一般，分为五个阶段分别设计

- 对于一个 MIPS指令包含如下5 个处理步骤：

  - **IF**: 从指令存储器中读取指令

  - **ID**: 指令译码的同时读取寄存器。 MIPS 的指令格式允许同时进行指令译码和读寄存器

  - **EX**: 执行操作或计算地址

  - **MEM**: 从数据存储器中读取操作数

  - **WB**: 将结果写回寄存器

- 书上的数据通路

![image-20241127101903970](D:\Internt_of_Thing\e_book\计算机组成原理\note\assets\image-20241127101903970-1732673946928-1.png)

- logisim实现，但内部未完善

![image-20241204075843244](D:\Internt_of_Thing\e_book\计算机组成原理\note\assets\image-20241204075843244-1733270326024-2.png)

## 对于控制信号

### Control

1. RegDst:写寄存器组的**地址来自rt还是rd**
   1. 当写地址来自rt,即**ori, lui,lw**指令的rt时，RegDst为状态 **0**
   2. 当写地址来自rd,即**addu, sub**指令的rd时，RegDst为状态 **1**
2. RegWrite:是否**往寄存器里写数据**
   1. 往寄存器里写数据时，即**ori, lui, addu, sub, lw**  为状态 **1**
   2. 不写时，即**bne, sw**     为  **0**
3. ALUSrc：第二个**操作数来自寄存器还是立即数扩展**
   1. 第二个**操作数来自寄存器**时 ,即**addu, sub, bne**，为**0**
   2. 第二个**操作数来自立即数扩展**时，即**ori, lui, lw, sw**,为 **1**
4. Branch(在表里为**PCSrc**):是否为**分支指令**
   1. 不是分支指令，为 **0**
   2. 是分支指令 ，即**bne**  为 **1** 
5. MemRead： 是否**读存储器**
   1. 不读，为**0**
   2. 读寄存器时，即**lw** ,为 **1**
6. MemWrite :是否**写存储器**
   1. 不写存储器 ，为 **0**
   2. 写存储器时， 即**sw**, 为**1**
7. MemtoReg:写回寄存器的值**来自ALU输出结果还是存储器输出**
   1. **ALU输出作为结果寄存器输入**，即**ori, lui, addu ,sub**, 为**1**
   2. **存储器输出作为结果寄存器输入**， 即**lw, sw** ,为**0**
8. ALUOP:**控制ALU的操作**
   1. 将操作码（opcode)传给ALUcontrol

所以对于上述指令集

![image-20241205133941654](D:\Internt_of_Thing\e_book\计算机组成原理\note\assets\image-20241205133941654-1733377183421-1.png)

### ALUcontrol

- 对于各个指令

![image-20241128160504264](D:\Internt_of_Thing\e_book\计算机组成原理\note\assets\image-20241128160504264.png)

所以定义**4种操作**,采用**二进制编码**

![image-20241128160553241](D:\Internt_of_Thing\e_book\计算机组成原理\note\assets\image-20241128160553241-1732781154267-7.png)

- 详细：

![image-20241205133959879](D:\Internt_of_Thing\e_book\计算机组成原理\note\assets\image-20241205133959879-1733377201746-3.png)



