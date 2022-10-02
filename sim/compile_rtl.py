'''
Date: 2022-04-14 01:12:21
LastEditors: Szang
LastEditTime: 2022-04-27 21:23:41
FilePath: \zarv\sim\compile_rtl.py
'''

import subprocess
import os.path
import sys
from pathlib import Path

def main():
    # rtl_dir = sys.argv[1]
    rtl_dir = '..'

    # iverilog程序
    iverilog_cmd = ['iverilog']

    # 编译生成文件
    iverilog_cmd += ['-o', r'out.vvp']
    # 头文件(defines.v)路径
    iverilog_cmd += ['-I', rtl_dir + r'/rtl/']
    # 宏定义，仿真输出文件
    # iverilog_cmd += ['-D', r'OUTPUT="signature.output"']
    # testbench文件
    iverilog_cmd.append(r'test_tb.v')
    # ../rtl
    iverilog_cmd.append(rtl_dir + r'/rtl/define.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/ex.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/id_ex.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/id.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/if_id.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/pc.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/rom.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/ram.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/regs.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/top.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/xbus.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/ctrl.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/csr_regs.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/intc.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/timer.v')

    # print(iverilog_cmd)

    # 编译
    process = subprocess.Popen(iverilog_cmd)
    process.wait(timeout=5)

    # 生成波形输出文件
    vvp_cmd = ['vvp', r'out.vvp']
    process = subprocess.Popen(vvp_cmd)
    process.wait(timeout=5)

    # 打开波形
    gtkw_path = Path("zarv.gtkw")
    if gtkw_path.is_file():
        gtkwave_cmd = ['gtkwave', r'zarv.gtkw']
    else:
        gtkwave_cmd = ['gtkwave', r"tb.vcd"]
    process = subprocess.Popen(gtkwave_cmd)


if __name__ == '__main__':
    sys.exit(main())
