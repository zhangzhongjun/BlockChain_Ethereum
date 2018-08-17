## 0s

停止操作和算术操作

如果没有特殊说明，所有算术操作都是模2^256的

规定任何数模0等于0

规定0^0等于1

规定底数为0时，

实现参考：https://github.com/ethereum/py-evm/blob/master/eth/vm/logic/arithmetic.py

| Opcode | Name | Description | Extra Info | Gas |
| --- | --- | --- | --- | --- |
| `0x00` | STOP | 终止执行 | - | 0 |
| `0x01` | ADD | 加法运算 | - | 3 |
| `0x02` | MUL | 乘法运算 | - | 5 |
| `0x03` | SUB | 减法运算 | - | 3 |
| `0x04` | DIV | 整数除法运算 | - | 5 |
| `0x05` | SDIV | 无符号整数除法运算 | - | 5 |
| `0x06` | MOD | 取模运算 | - | 5 |
| `0x07` | SMOD | 带符号整数除法运算 | - | 5 |
| `0x08` | ADDMOD | 模加运算 | (x1 + x2) mod x3 | 8 |
| `0x09` | MULMOD | 模乘运算 | （x1 * x2） mod x3 | 8 |
| `0x0a` | EXP | 幂运算 | - | 取决于指数的字节数 |
| `0x0b` | SIGNEXTEND | 将一个数符号扩展为256比特 | 第一个参数是现在的字节数，第二个参数是要扩展的数字 | 5 |
| `0x0c` - `0x0f` | Unused | Unused | - |

## 10s

逻辑运算和位运算


如果逻辑运算成立则输出1，否则输出0


以LT为例，如果有两个输入x1和x2，如果x1<x2，则输出1；否则输出0


实现参考：https://github.com/ethereum/py-evm/blob/master/eth/vm/logic/comparison.py


| Opcode | Name | Description | Extra Info | Gas |
| --- | --- | --- | --- | --- |
| `0x10` | LT | 小于 | - | 3 |
| `0x11` | GT | 大于 | - | 3 |
| `0x12` | SLT | 带符号数的小于 | - | 3 |
| `0x13` | SGT | 带符号数的大于 | - | 3 |
| `0x14` | EQ | 相等 | - | 3 |
| `0x15` | ISZERO | 判断一个数是否为0 | - | 3 |
| `0x16` | AND | 按位与 | - | 3 |
| `0x17` | OR | 按位或 | - | 3 |
| `0x18` | XOR | 按位异或 | - | 3 |
| `0x19` | NOT | 按位取反 | - | 3 |
| `0x1a` | BYTE | 从字（256 bits）中取出一个byte（8 bits） | 第一个参数是要取第几个byte，第二个参数是数字 | 3 |


### 从py-evn中看 BYTE 操作的具体实现

```python
def byte_op(computation):
    # 从栈中取出两个参数 第一个参数是要取第几个byte，第二个参数是数字
    position, value = computation.stack_pop(num_items=2, type_hint=constants.UINT256)
	# 如果要取第 >= 32个字节，则返回0
	# 这是因为evm中字长为32字节
    if position >= 32:
        result = 0
    else:
    	# x//(2^y)，相当于将x右移y位
    	# pow(256,31-position) = 2^(8*(31-position))
    	# %256是为了去掉高位的数据
        result = (value // pow(256, 31 - position)) % 256

    computation.stack_push(result)
```

举例，position=1，value = 00000110 01100110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 00000110 = 0x 06 66 06 06 06 06 06 06 06 06 06 06 06 06 06 06 06 06 06 06 06 06 06 06 06 06 06 06 06 06 06 06



pow(256, 31 - position) = 2^(8 \* 30) = 2^240

value//(2^240) = 0x 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 06 66

result = value//(2^240) % 256 = 0x 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 66

至此，我们取出了位置1处的byte

## 20s


实现参考：https://github.com/ethereum/py-evm/blob/master/eth/vm/logic/comparison.py


| Opcode | Name | Description | Extra Info | Gas |
| --- | --- | --- | --- | --- |
| `0x20` | SHA3 | 计算Keccak-256哈希值 | - | 取决于原象的字数 |
| `0x21` - `0x2f`| Unused | Unused |


## 30s

用于获取环境信息的操作符

实现参考 https://github.com/ethereum/py-evm/blob/master/eth/vm/logic/context.py


| Opcode | Name | Description | Extra Info | Gas |
| --- | --- | --- | --- | --- |
| `0x30` | ADDRESS | 获得调用者的存储地址 | - | 2 |
| `0x31` | BALANCE | 获得给定账户的余额 | 输入要查询的账户的地址，返回该账户的余额 | 400 |
| `0x32` | ORIGIN | 获得调用者的地址 | 输出交易发起人（一定是外部账户）的地址 | 2 |
| `0x33` | CALLER | 获得调用者的地址 | 对本次调用的直接负责者，可能是外部账户，也可能是合约账户 | 2 |
| `0x34` | CALLVALUE | 获得该次交易的值 | - | 2 |
| `0x35` | CALLDATALOAD | 获得当前环境中的输入数据 | 当前环境中的输入数据与交易传递的数据有关 | 3 |
| `0x36` | CALLDATASIZE | 获得当前环境中的输入数据的长度 | 当前环境中的输入数据与交易传递的数据有关 | 2 |
| `0x37` | CALLDATACOPY | 将当前环境中的输入数据拷贝至内存中 | - | 3 |
| `0x38` | CODESIZE | 获得代码的长度 | - | 2 |
| `0x39` | CODECOPY | 将一段智能合约代码拷贝至内存中 | 输入有三个，分别是内存偏移量，代码偏移量，大小 | 取决于代码的字数 |
| `0x3a` | GASPRICE | 获得当前环境下的gasPrice | - | 2 |
| `0x3b` | EXTCODESIZE | 获得某个合约账户的代码的长度 | 输入为合约账户的地址，输出为该合约账号下面的代码的长度 | 700 |
| `0x3c` | EXTCODECOPY | 将一段智能合约代码拷贝至内存中 | - | 取决于代码的字数 |
| `0x3d` | RETURNDATASIZE | 获得数据缓存区中的数据的长度 | [EIP 211](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-211.md) | 2 |
| `0x3e` | RETURNDATACOPY | 将数据缓存区中的数据拷贝至内存中 | [EIP 211](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-211.md) | 3 |
| `0x3f` | 获得一段智能合约代码的keccak256哈希值 | - |[EIP 1052](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1052.md)|400|

一个外部账户发出命令，调用某个合约账户中的代码；这个合约账户中的代码又有可能去调用另外一个合约账户中的代码。



origin指令获得的地址是外部账户的地址


caller指令获得的地址可能是外部账户的地址，也可能是合约账户的地址