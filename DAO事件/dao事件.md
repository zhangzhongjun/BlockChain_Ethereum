# the DAO攻击事件

> 2016年6月18日，以太坊上爆发了the DAO攻击事件，该事件直接导致了以太坊的硬分叉，同时让以太坊社区分裂为ETH和ETC两个社区。
> 在the DAO攻击发生两周年之际，我们回过头来细细回顾这起事件。搞起其中的原理，帮助我们编写出更好、更健壮的dapp。


## 一些重要的合约地址：

黑客发动攻击的地址：  0xf35e2cc8e6523d683ed44870f5b7cc785051a77d
黑客使用的代理：0xf835a0247b0063c04ef22006ebe57c5f11977cc4
黑客使用的代理：0x56bcc40e5e76c658fad956ee32e4250bf97468a1

TheDAO是被攻击的合约；TheDarkDAO是黑客写的、用于吸取DAO中eth的合约；WhiteHatDAO是一帮白帽子写的，同样是为了吸取DAO中的eth。
在攻击时间后，DAO合约并没有停止更新，其GITHUB上的代码一直保持更新，现在最新版已经是修复之后的版本了。各位朋友想要研究出问题的代码的话可以看网友fork的DAO1.0的git仓库。

TheDAO合约: https://etherscan.io/address/0xbb9bc244d798123fde783fcc1c72d3bb8c189413#code
TheDarkDAO合约: https://etherscan.io/address/0x304a554a310C7e546dfe434669C62820b7D83490
WhiteHatDAO: https://etherscan.io/address/0xb136707642a4ea12fb4bae820f03d2562ebff487
WhitehatDao2: https://etherscan.io/address/0x84ef4b2357079cd7a7c69fd7a37cd0609a679106
未命名： https://etherscan.io/address/0xf4c64518ea10f995918a454158c6b61407ea345c
未命名： https://etherscan.io/address/0xaeeb8ff27288bdabc0fa5ebb731b6f409507516c


dao项目地址，不断更新
https://github.com/slockit/DAO


网友fork的dao-1.0版本，是发生攻击时候的合约版本。本文是在该版本的基础上进行分析的：
https://github.com/TheDAO/DAO-1.0

## 代码分析

DAO合约中的
DAO.sol：DAO的标准智能合约，用于管理自治组织并进行决策
DAOTokenCreationProxyTransferer.sol：用于创建一种新的代币体系，因为新DAO需要有自己的token体系。
ManagedAccount.sol：基本的账户，用来管理reward账号和extraBalance账户。
SampleOffer.sol：开发小组给出一个示例offer，演示了从合同商到DAO组织的offer应该怎么写
Token.sol：检查token的余额，发送token，代表第三方发送相应的代币
TokenCreation.sol：创建Token的智能合约，用来出售token获得初始的eth。

项目的主要文件就是DAO.sol，下面我们从DAO.sol开始分析

### splitDAO函数的定义如下（DAO.sol 240行）：
```solidity
/// @notice ATTENTION! I confirm to move my remaining ether to a new DAO
/// with `_newCurator` as the new Curator, as has been
/// proposed in proposal `_proposalID`. This will burn my tokens. This can
/// not be undone and will split the DAO into two DAO's, with two
/// different underlying tokens.
/// @param _proposalID The proposal ID 用户提议的proposal的ID
/// @param _newCurator The new Curator of the new DAO新DAO的管理者
/// @dev This function, when called for the first time for this proposal,
/// will create a new DAO and send the sender's portion of the remaining
/// ether and Reward Tokens to the new DAO. It will also burn the DAO Tokens
/// of the sender.
function splitDAO(
    uint _proposalID,
    address _newCurator
) returns (bool _success);
```

如果你不同意某个提议或负责人，想要分割DAO，你可以调用该函数。这是去确保DAO的去中心化和自治。
你应该明白分割并不是很难，只是需要一些步骤和时间。需要（最少）7天分割DAO，来将你的的以太币和奖励代币转移到某个地址，使它完全在你的掌控之中。尽管如此，仍然需要48天去“提现”以太币到标准的账户，然后你就可以发送或者交易。你需要一些操作，等待7天，再操作，再等待27天，再操作，再等待14天，然后最终以太币才会回到你掌控的帐号中。

详细的分隔流程见：https://ethfans.org/posts/split-the-dao-get-back-ether

### splitDAO函数的实现如下(DAO.sol 599行)：
```solidity
function splitDAO(
	uint _proposalID,
	address _newCurator
) noEther onlyTokenholders returns (bool _success) {
	bla bla bla...
}
```
该函数不发送eth，只能被持有token的人调用。

608~621行做正确性验证，检查投票是否截至，是否过期等等

623~637行检查新的DAO是否已经存在，如果不存在则会新建一个DAO

639行开始，是真正重要的地方：
```solidity
// 计算出应该向调用者发送多少eth
uint fundsToBeMoved =
(balances[msg.sender] * p.splitData[0].splitBalance) /
p.splitData[0].totalSupply;
// 创建token的方法
if (p.splitData[0].newDAO.createTokenProxy.value(fundsToBeMoved)(msg.sender) == false)
	throw;


// Assign reward rights to new DAO
uint rewardTokenToBeMoved =
(balances[msg.sender] * p.splitData[0].rewardToken) /
p.splitData[0].totalSupply;

uint paidOutToBeMoved = DAOpaidOut[address(this)] * rewardTokenToBeMoved /
rewardToken[address(this)];

rewardToken[address(p.splitData[0].newDAO)] += rewardTokenToBeMoved;
if (rewardToken[address(this)] < rewardTokenToBeMoved)
	throw;
rewardToken[address(this)] -= rewardTokenToBeMoved;

DAOpaidOut[address(p.splitData[0].newDAO)] += paidOutToBeMoved;
if (DAOpaidOut[address(this)] < paidOutToBeMoved)
	throw;
DAOpaidOut[address(this)] -= paidOutToBeMoved;

// 注意这里，为msg.sender记录的dao币余额归零、扣减dao币总量totalSupply等等都发生在将发回msg.sender之后，这是一个典型“反模式”。
Transfer(msg.sender, 0, balances[msg.sender]);
// 调用withdrawRewardFor函数
withdrawRewardFor(msg.sender); // be nice, and get his rewards
totalSupply -= balances[msg.sender];
balances[msg.sender] = 0;
paidOut[msg.sender] = 0;
return true;
```

### withdrawRewardFor函数（DAO.sol 716行）
```solidity
function withdrawRewardFor(address _account) noEther internal returns (bool _success) {
	if ((balanceOf(_account) * rewardAccount.accumulatedInput()) / totalSupply < paidOut[_account])
		throw;

	uint reward =
(balanceOf(_account) * rewardAccount.accumulatedInput()) / totalSupply - paidOut[_account];
	// 调用paidOut函数
    if (!rewardAccount.payOut(_account, reward))
		throw;

	paidOut[_account] += reward;
	return true;
}
```

### payOut函数（ManagedAccount.sol 57行）
```solidity
function payOut(address _recipient, uint _amount) returns (bool) {
	// 正确性检查
	// 1. 只有该账户的拥有者才能调用该函数
	// 2. 只能转移大于零的数额
	// 3. 如果设置了只能给自己转账，则不能将以太币转移给其他人
	if (msg.sender != owner || msg.value > 0 || (payOwnerOnly && _recipient != owner))
		throw;
	// 调用call来完成转账
	// 注意这里 _recipient.call.value(_amount)()是不需要消耗gas的
	if (_recipient.call.value(_amount)()) {
		PayOut(_recipient, _amount);
		return true;
	} else {
		return false;
	}
}
```

## 攻击

1. 创建一个钱包合约，在合约中写一个默认函数，在默认函数多次调用splitDAO函数，不要调用太多的次数
2. 创建一个分割协议，设置参数recipient（指的是该协议的负责人）为第一步中的钱包地址
3. 等待7天的分割期
4. 调用splitDAO函数

调用栈如下
```
提交split proposal
	调用splitDao函数（手动调用）
		调用createNewDAO函数（如果不是第一次调用，则不会调用该函数）
		调用withdrawRewardFor函数，用于归还奖励token
		调用payOut函数
			调用recipient.call.value()函数
				再次调用splitDao函数（手动调用）
					调用withdrawRewardFor
					调用payOut函数
					调用recipient.call.value()函数
```

1. 提出一个split然后等待直达表决期限到期。（DAO.sol, createProposal）
2. 运行split。（DAO.sol, splitDAO）
3. 让DAO发送一份额的代币到新DAO(splitDAO -> TokenCreation.sol, createTokenProxy)
4. 确保DAO在（3）之后在更新你的余额之前尝试发送给你收益。（splitDAO -> withdrawRewardFor -> ManagedAccount.sol, payOut）
5. 当DAO在步骤（4）时，以与（2）相同的参数再次运行splitDAO 。（payOut -> _recipient.call.value -> _recipient()）
6. DAO将会发送给你更多的子代币，并在更新你的余额之前撤销对你的收益。（DAO.sol, splitDAO）
7. 返回（5）！
8. 让DAO更新你的余额。因为（7）返回到（5），所以这将不会发生。

综合以上思路，攻击者想要达到两个目的：
1. 能够持续运行这个合约。即迭代运行。 
2. 能够利用漏洞，转钱到自己的账户，且不会因为交易费机制而终止交易。即交易成本要低于转账总额。

## 攻击分析

### 应用代码顺序方面

应先扣减dao的余额再转账Ether，因为dao的余额检查作为转账Ether的先决条件，要求dao的余额状况必须能够及时反映最新状况。在问题代码实现中，尽管最深的递归返回并成功扣减黑客的dao余额，但此时对黑客dao余额的扣减已经无济于事，因为其上各层递归调用中余额检查都已成功告终，已经不会再有机会判断最新余额了。

### 不受限制地执行未知代码方面

虽然黑客当前是利用了solidity提供的匿名fallback函数，但这种对未知代码的执行原则上可以发生在更多场景下，因为合约之间的消息传递完全类似于面向对象程序开发中的方法调用，而提供接口等待回调是设计模式中常见的手法，所以完全有可能执行一个未知的普通函数。

## 软分叉

为了解决TheDAO大量资金被盗的问题，尽管争议颇多，以太坊官方还是推出了针对TheDAO的软分叉版本Gethv1.4.8，该版本增加了一些规则以锁定黑客控制的以太币，以便有更多时间留给社区去解决TheDAO的问题。在六月底的数据显示，绝大多数矿工都升级了这个版本的软件，眼看着软分叉就要大功告成了。

也许TheDAO就是命运多舛，不知是否因为时间仓促，众多大牛编写出来的软分叉版本居然又有漏洞！这个漏洞比较明显，简单地说，每个以太坊上的交易，验证节点（矿工）都会检查是否与TheDAO智能合约及其子DAO的地址相关。如果是则拒绝这个交易，从而锁定TheDAO（包括黑客在内）的所有资金。这个逻辑实现本身并没有问题，但是却没有收取执行交易的燃料费（gas）。当初以太坊设计的gas有两个作用：支付矿工的交易费和增加潜在攻击者的成本。取消交易燃料费后，导致了非常严重的后果：以太坊网络成为了DoS（DenialofService）的攻击目标（如同我国高速公路在法定节假日免费通行造成大塞车的情况一样），攻击者可以零成本地发起大量攻击，使得整个网络彻底瘫痪。因为这个漏洞，各个节点回滚了软件版本，软分叉方案失败！

## 参考文献

https://ethfans.org/topics/242 参与众筹的详细步骤
https://ethfans.org/posts/114 中文的对攻击的分析
https://ethfans.org/topics/351  The DAO 合约攻击信息汇总
https://ethfans.org/posts/split-the-dao-get-back-ether 分割dao的教程
https://vessenes.com/deconstructing-thedao-attack-a-brief-code-tour/
https://vessenes.com/more-ethereum-attacks-race-to-empty-is-the-real-deal/
https://www.jubi.com/shanzhaibi/1748.html