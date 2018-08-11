# truffle框架

## truffle.js

位于项目的根目录下，是项目的配置文件。

## 使用例子项目

> truffle框架提供了一些例子项目

```bash
mkdir MetaCoin
cd MetaCoin
truffle unbox metacoin
```

### 项目结构

* contracts/: Directory for Solidity contracts
* contracts/Migration.sol：truffle提供的迁移功能，在执行truffle init之后被自动创建
* migrations/: Directory for scriptable deployment files
* test/: Directory for test files for testing your application and contracts
* truffle.js: Truffle configuration file
* truffle-config.js: 

## 合约迁移

迁移脚本是由一些Javascript文件组成的，用来帮助你把合约发布到以太坊网络中。

之所以需要迁移脚本是因为你的部署需求会随着时间改变，随着你的项目的发展，你可以创建新的迁移脚本把这些变化的合约部署到以太坊网络中。

之前你运行的迁移历史记录，会被一个特殊的Migrations.sol合约记录在区块链上。

在执行truffle init之后，会在contracts文件夹下自动生成一个Migration.sol文件

```solidity
pragma solidity ^0.4.2;

contract Migrations {
  address public owner;
  uint public last_completed_migration;

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  constructor() public {
    owner = msg.sender;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }

  function upgrade(address new_address) public restricted {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}
```

为了部署上面谈到的Migration.sol 合约，需要一个迁移脚本migrations/1_initial_migrations.js
```javascript
var Migrations = artifacts.require("./Migrations.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};
```

## 流程

初始化truffle项目
```bash
truffle init
```

只编译自上次编译以来修改的东西：
```bash
truffle compile
```

编译全部的文件
```bash
truffle compile --all
```

执行新的迁移脚本
```bash
truffle migrate
```

执行全部的迁移脚本
```bash
truffle migrate --reset
```

## deployer对象详解

你的迁移脚本会使用这deployer对象来组织部署任务。deployer对象会同步执行部署任务，因此你可以按顺序编写部署任务。

```javascript
// 先部署A，再部署B
deployer.deploy(A);
deployer.deploy(B);
```

另外，deployer上的每一个函数都会返回一个promise，通过promise可以把有执行顺序依赖关系的部署任务组成队列。

```javascript
// 部署A, 然后部署 B, 把A 部署后的地址传给B
deployer.deploy(A).then( function () {
	return deployer.deploy(B, A.address);
});
```

### deployer对象的api

1. deployer.deploy(CONTRACT, ARGS…, OPTIONS)

这个API是用来部署合约的
* contract参数传入需要部署的合约名字
* args参数传入合约的构造函数需要的参数
* options是一个可选参数它的值是{overwrite: true/false}， 如果 overwrite 被设置成 false, 那么当这个合约之前已经部署过了，这个deployer就不会再部署这个合约，这在当一个合约的依赖是由一个外部合约地址提供的情况下是有用的。

为了快速进行部署多个合约，你可以向deployer.deploy(.....)函数中传入一个或多个数组。

例子:
```javascript
// 部署单个合约,不带任何构造参数
deployer.deploy(A);
// 部署单个合约带有构造参数
deployer.deploy(A, arg1, arg2, ...);
// 部署多个合约,一些带构造参数,一些不带构造参数.
// 比写3次 `deployer.deploy()` 语句更快, 因为deployer可以把所有的合约部署都一次性打包提交
deployer.deploy([
[A, arg1, arg2, ...],
B,
[C, arg1]
]);
// 外部依赖的例子:
//
// overwrite: false 表示，如果 SomeDependency 合约之前已经被部署过，那么不在重新部署，直接使用之前已部署好的地址
// 如果我们的合约要运行在自己的测试链上，或者将要运行的链上没有SomeDependency合约，
// 那么把overwrite: false改成overwrite: true，表示不在检查之前SomeDependency有没有部署过，一律覆盖部署。
deployer.deploy(SomeDependency, {overwrite:  false});
```


2. deployer.link(LIBRARY, DESTINATIONS)

把一个已部署好的库链接到一个或多个合约里。

destinations 可以传入一个合约，也可以传入一组合约。如果 destinations中的某个合约不依赖这个库, 那deployer 的link函数就会忽略这个合约。

```javascript
// 部署库LibA,然后把LibA 链接到合约B,然后部署合约B.
deployer.deploy(LibA);
deployer.link(LibA, B);
deployer.deploy(B);

//库LibA链接到多个合约
deployer.link(LibA, [B, C, D]);
```

3. deployer.then(function() {...})

在迁移过程中使用它调用特定合约的函数来部署新的合约，为已部署的合约做一些初始化工作等。

例子:

```javascript
var a, b;
deployer.then( function() {
    // 部署合约A的一个新版本到网络上
    return A.new();
    }).then( function(instance) {
        a = instance;
        // 获取已部署的合约B的实例
        return B.deployed();
        }).then( function(instance) {
            b = instance;
            // 使用合约B的setA()方法设置A的地址的新实例.
            return b.setA(a.address);
});
```

4. 网络相关

在执行迁移时，迁移脚本会把truffle.js里配置的networks传递给你，你可以在module.exports导出函数中第二个参数位置接受这个值。

文件：truffle.js

```javascript
module.exports = {
networks: {
  development: {
    host: "localhost",
    port: 8545,
    network_id: "*" // Match any network id
  }
}
};
```

```javascript
module.exports=function(deployer, network) {
    if(network=="live") {
		// 当不在"live"的网络上的时候，做一些特定的操作.
    } else{
		// 当在的时候，做一些其他的操作.
    }
}
```

5. 可用的账户

在执行迁移时，迁移脚本会把当前以太坊客户端或web3.provider中可用的账户列表传递给你，这个列表与web3.eth.getAccounts()返回的账户列表完全一样。你可以在module.exports导出函数中第三个参数位置接受这个值。

```javascript
module.exports=function(deployer, network, accounts) {
	//在你的迁移脚本中使用账户
}
```

## 合约交互

以太坊中将向以太坊网络写入数据和从以太坊网络中读取数据这两种操作做了区分。

写数据被称为交易（transaction），而读取数据称为调用（call）。

### 交易（transaction）

交易会从根本上改变了网络的状态。简单的交易有：发送以太币到另一个账户。复杂的交易有：调用一个合约的函数，向网络中部署一个合约。

当你通过交易调用合约的函数时，我们将无法立即获得智能合约的返回值，因为该交易当前只是被发送，离被打包、执行还有一段时间。通常，通过交易执行的函数将不会立刻返回值，它们将返回一个交易ID。所以总结一下，一个交易一般有如下特征：
>消耗gas（以太币）
>更改网络的状态
>不会立即处理
>不会立刻返回一个返回值（只有一个交易ID）

### 调用（CALL）

调用是用来读取数据。调用是：

>是免费的（不消耗gas）
>不会更改网络的状态
>会被立即处理
>会立刻返回一个值

决定使用交易还是调用，依据很简单：要读取数据还是写入数据。

### 合约抽象

合约抽象是Javascript和以太坊合约交互的中间层粘合剂。简而言之，合约抽象帮我们封装好了代码，它可以让你和合约之间的交互变得简单，从而让你不必关心合约调用细节。

Truffle通过truffle-contract模块来使用自己的合约抽象。合约抽象中的函数和我们合约中的函数是一样的。

为了使用合约抽象和合约交互，我们需要通过npm安装truffle-contract模块

```bash
$ cd myproject
$ npm init -y
$ npm install --save truffle-contract@3.0.1
$ npm install --save web3@0.20.0
```

### 这里给出Storage.sol合约

```solidity
pragmasolidity^0.4.8;

contract Storage{

uint256 storedData;

function set(uint256 data) {
	storedData=data;
}

function get() constant returns(uint256) {
	return storedData;
}
}
```

### 与合约交互

1. Transaction 方式交互

接下来我们以transaction方式给Storage.sol合约中storedData变量赋值为42，

文件：transaction.js
```javascript
varWeb3=require("web3");

varcontract=require("truffle-contract");
vardata=require("../build/contracts/Storage.json");

// 返回合约抽象
var Storage=contract(data);

var provider=newWeb3.providers.HttpProvider("http://localhost:8545");
Storage.setProvider(provider);

var storageInstance;
Storage.deployed().then(function(instance) {
   storageInstance=instance;

   //以transaction方式与合约交互
   return storageInstance.set(42,{from:Storage.web3.eth.accounts[0]});
}).then(result=>{
    // result 是一个对象，它包含下面这些值：
    //
    // result.tx     => 交易hash，字符型
    // result.logs   => 在交易调用中触发的事件，数组类型
    // result.receipt => 交易的接收对象，里面包含已使用的gas 数量

	console.info(result.tx);//返回交易ID
}).then(()=>{
    // 调用Storage get 方法。这里是call的交互方式
    return storageInstance.get.call();
}).then(result=>{
   console.info(result.toString());// 返回 42 ，说明我们之前的调用成功了！
}).catch(err=>{
   // 报错了！在这里处理异常信息
});
```

2. Call 方式交互

介绍完上述概念后，现在我们可以和之前部署好的Storage.sol合约交互了，首先我们以call方式调用合约。

文件：call.js

```javascript
var Web3=require("web3");

var contract=require("truffle-contract");
var data=require("../build/contracts/Storage.json");

// 返回合约抽象
var Storage=contract(data);

var provider=newWeb3.providers.HttpProvider("http://localhost:8545");
Storage.setProvider(provider);

// 通过合约抽象与合约交互
Storage.deployed().then(function(instance) {
   return instance.get.call(); // call 方式调用合约
}).then(result=>{
   console.info(result.toString());// return 0
}).catch(err=>{
   // 报错了！在这里处理异常信息
});
```