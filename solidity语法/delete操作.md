# 出发点

区块链作为一种公用资源，为了避免滥用，会鼓励智能合约主动对空间进行回收，回收空间之后将会返回一些GAS

因为如果映射或数组非常大的情况下，删除或维护它们将变得非常消耗。不过，清理空间，可以获得gas的返还。但无特别意义的数组的整理和删除，只会消耗更多gas，需要在业务实现上进行权衡。

清理的最佳实践

由于本身并未提供对映射这样的大对象的清理，所以存储并遍历它们来进行清理，显得特别消耗gas。一种实践就是能复用就复用，一般不主动清理。

# 初始值

|     数据类型      |       初始值       |
| :-----------: | :-------------: |
|   bool    | false |
|   uint    |  0    |
| address   | 0x0   |
| bytes memory  | 0x0   |
| string memory | ""   |

删除bool, uint, address. bytes memory, string memory类型的变量将会将其置为初始值


# 枚举

```solidity
pragma solidity 60.4.0

contract DeleteEnum{
  enum Light{RED, GREEN, YELLOW}
  
  Light light;
  
  functin f() returns(Light){
    light = Light.GREEN
    
    delete light;
    // RED
    return light;
  }
}
```

在上面的例子中，删除light之后，light将会被置为序号为0的值，既RED


# 数组 

对于定长数组，将数组中的所有元素都 置为初始值

对于变长数组，将数组的长度置为0

可以删除数组中的一个元素，删除之后，数组会留一个空隙在哪里（置为初始值），其余的元素不变

```solidity
pragma solidity ^0.4.0;

contract DeleteArray{
  function deleteDynamicArr() returns(uint){
    uint[] memory a = new uint[](7);
    a[0] = 100;
    a[1] = 200;
    
    delete a;
    
    // 0
    return (a.length);
  }
  
  function deleteStaticArr() returns(bytes32){
    bytes32 by = "123";
    delete by;
    //0x0000000000000000000000000000000000000000000000000000000000000000
    return by;
  }
  
  function deleteArrayEle() returns(uint, uint, uint){
    uint[] memory a = new uint[](3);
    a[0] = 100;
    a[1] = 200;
    a[2] = 300;
    
    delete a[1];
    
    // 0
    return (a[0], a[1], a[2]);
  }
  
}
```

# 结构体

```solidity
pragma solidity ^0.4.0;

contract DeleteStruct{
  struct S{
    uint a;
    string b;
    bytes memory c;
    address d;
    mapping(address => uint) e;
  }
  
  S s;
  
  function delStruct() returns (uint, string, bytes){
    s = S(10,"hello world", "abc", msg.sender, );
    
    delete S;
    // 0 "" 0x0
    return (s.a, s.b, s.c)
  }
}
```

删除一个结构体，会将其中的所有成员变量一一置为初值

遇到类型为mapping的成员变量，直接跳过


# 映射

不能删除映射，会抛出如下的异常

```bash
Unary operator delete cannot be applied to type mapping
```

# 函数

不能删除函数













