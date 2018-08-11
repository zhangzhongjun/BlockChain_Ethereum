# 项目代码分析

> 更加详细的注释请参考我注释的The DAO项目
> 

## 修改器

Dao.sol中定义的：
onlyTokenholders: 只有代币的持有者才能调用

Token.sol中定义的：
noEther: 如果一个交易是带以太币的，则该交易不能调用该函数。

## 项目结构

Token.sol：检查token的余额，发送token，代表第三方发送相应的代币
TokenCreation.sol：创建Token的智能合约，用来出售token获得初始的eth。
DAO.sol：DAO的标准智能合约，用于管理自治组织并进行决策
DAOTokenCreationProxyTransferer.sol：
ManagedAccount.sol：是一个合约账户，用来管理reward账户和extraBalance账户，规定账户中的以太币的行为。
SampleOffer.sol：开发小组给出一个示例offer，演示了从合同商到DAO组织的offer应该怎么写


## Token.sol

allowed的结构如下：addr1允许addr2从自己的账户中转amount数量的DAO代币给另外一个账户。

![allowed的结构](imgs/allowed的结构.png)


操作allowed的方法有approve allowence，分完成对allowed的写和读操作。


## TokenCreation.sol 

该智能合约完成公募时候发行DAO代币的功能

注意DAO 代币的单位和以太币的单位完全一样，即wei Kwei Mwei Gwei 。The DAO的公募周期为28天 2*7 + 10 + 4 = 28天。

前2周的兑换比例是1：1，即一个以太币兑换一个DAO代币；接下来的10天兑换比例线性减少；最后的4天兑换比例为1：0.6。

之所以要设置这种浮动价格，是因为越早参与重筹，则承担的风险也就越大。但是，这种浮动价格机制打来了另外一个问题，即在众筹结束之后，早期用户可能通过分割DAO的方式取回更多的eth来牟利。

为了防止这个问题，The DAO设置了另外一个账户，extraBalance，所有在众筹后14天募集到的以太币都将被发送到这个账户中。



