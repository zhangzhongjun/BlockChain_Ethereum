## 修改器

* 修改器(Modifiers)可以用来轻易的改变一个函数的行为。比如用于在函数执行前检查某种前置条件。
* 修改器是一种合约属性，可被继承
* 修改器还可被派生的合约重写(override)
* 修改器可以接收参数

```javascript
pragma solidity ^0.4.0;

contract owned {
    address owner;
    function owned() { owner = msg.sender; }

    // 定义了一个修改器，被该修改器修改的函数将会被放在 _ 的位置
    // 该修改器用于检查函数的调用这是否和存储的owner相同，如果不一样，则抛出异常；否则执行 _ 处被替换的函数。
    modifier onlyOwner {
        if (msg.sender != owner)
            throw;
        _;// 函数的主体将会被放置在这里
    }
}
```

```javascript
contract mortal is owned {
    // mortal从owned中继承了 onlyOwner修改器
    function close() onlyOwner {
        selfdestruct(owner);
    }
}
```

```javascript
contract priced {
    // 修改器可以接收参数。该修改器表示只有交易的金额大于price是，该函数才会被执行
    modifier costs(uint price) {
        if (msg.value >= price) {
            _;
        }
    }
}
```

```javascript
contract Register is priced, owned {

    uint price;
    mapping (address => bool) registeredAddresses;


    function Register(uint initialPrice) { 
    	price = initialPrice;
    }

    // 可以多继承，payable的意思是可以接收带ether的交易
    function register() payable costs(price) {
        registeredAddresses[msg.sender] = true;
    }

	// 从智能合约owned中继承下来的onlyOwner修改器
    function changePrice(uint _price) onlyOwner {
        price = _price;
    }
}

```

使用修改器实现的一个防重复进入的例子：例子中，由于call()方法有可能会调回当前方法，修改器实现了防重入的检查。
```javascript
pragma solidity ^0.4.0;
contract Mutex {
    bool locked;
    modifier noReentrancy() {
        if (locked) throw;
        locked = true;
        _;
        locked = false;
    }

    // 该修改器用于保证在同一时刻只有一个调用者可以调用该函数
    function f() noReentrancy returns (uint) {
        if (!msg.sender.call()) throw;
        return 7;
    }
}
```