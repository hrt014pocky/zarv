<!--
 * @Date: 2022-04-13 23:11:35
 * @LastEditors: Szang
 * @LastEditTime: 2022-04-16 12:42:38
 * @FilePath: \zarv\README.md
-->

# zarv
ZARV项目是一个32位RISC-V处理器，采用三级流水线结构，rtl代码使用Verilog HDL语言编码。参考开源项目Tinyriscv。

## 硬件结构

### pc寄存器

|序号|信号名|输入/输出|位宽(bits)|说明|
|-|-|-|-|-|
|1|clk                   |input |1 |时钟输入信号   |
|2|rst_n                 |input |1 |复位输入信号   |
|3|jump_flag_i           |input |1 |跳转标志       |
|4|jump_addr_i           |input |1 |跳转地址       |
|5|hold_flag_i           |input |1 |流水线暂停标志 |
|6|jtag_reset_flag_i     |input |1 |复位标志       |
|7|pc_o                  |output|32|PC指针         |

### if_id
取指寄存器
|序号|信号名|输入/输出|位宽(bits)|说明|
|-|-|-|-|-|
|1|clk                   |input |1 |时钟输入信号   |
|2|rst_n                 |input |1 |复位输入信号   |
|3|inst_addr_i           |input |32|指令地址输入   |
|4|inst_i                |input |32|指令内容输入   |
|5|inst_addr_o           |output|32|指令地址输出 |
|6|inst_o                |output|32|指令内容输出 |

## 学习遇到的问题
1. xbus一个时钟周期只能处理一对主从关系数据读写。当有ex模块使用总线时，pc单元不在从内存中取指，导致pc的计数器仍在累加，但并没有取出指令。Tinyriscv的处理方法是：在此刻pc寄存器的流水线暂停标志要被挂起，pc寄存器不在向上计数。取出的指令是NOP，暂停期间的几条NOP指令不做任何动作。
