'''
Date: 2022-05-15 13:11:15
LastEditors: Szang
LastEditTime: 2022-05-15 13:12:57
FilePath: \zarv\sim\fsm_design\test.py
'''

import subprocess
import sys
from pathlib import Path

def main():
    # rtl_dir = sys.argv[1]
    # rtl_dir = '.'

    # iverilog程序
    iverilog_cmd = ['iverilog']

    # 编译生成文件
    iverilog_cmd += ['-o', r'out.vvp']
    # 头文件(defines.v)路径
    # iverilog_cmd += ['-I', rtl_dir + r'/rtl/']
    # 宏定义，仿真输出文件
    # iverilog_cmd += ['-D', r'OUTPUT="signature.output"']
    # testbench文件
    iverilog_cmd.append(r'test_tb.v')
    # ../rtl
    iverilog_cmd.append(r'test.v')

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
