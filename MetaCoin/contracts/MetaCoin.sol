pragma solidity ^0.4.18;

import "./ConvertLib.sol";

// This is just a simple example of a coin-like contract.
// It is not standards compatible and cannot be expected to talk to other
// coin/token contracts. If you want to create a standards-compliant
// token, see: https://github.com/ConsenSys/Tokens. Cheers!

contract MetaCoin {

	// 存储金额的变量
	mapping (address => uint) balances;

	// 转账的事件
	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	// 构造函数，向函数调用者的账户充值10000元
	constructor() public {
		balances[tx.origin] = 10000;
	}

	// 向某个账户中转账，发送者为函数的调用者，而接受者有参数receiver指定
	function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
		// 合法性检验 函数调用者的
		if (balances[msg.sender] < amount) return false;
		// 将发送者的账户余额减去amount
		balances[msg.sender] -= amount;
		// 将接收者的账户余额加上amount
		balances[receiver] += amount;
		// 触发一个事件
		emit Transfer(msg.sender, receiver, amount);
		// 返回true		
		return true;
	}
	// 获得余额，单位为以太坊的个数
	function getBalanceInEth(address addr) public view returns(uint){
		return ConvertLib.convert(getBalance(addr),2);
	}
	// 获得余额，单位为代币个数
	function getBalance(address addr) public view returns(uint) {
		return balances[addr];
	}
}
