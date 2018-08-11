pragma solidity ^0.4.4;


// 转化的库函数 金额 乘以 汇率，汇率为以太币兑换代币个数
// 即一个以太币兑换conversionRate个代币 
library ConvertLib{
	function convert(uint amount,uint conversionRate) public pure returns (uint convertedAmount)
	{
		return amount * conversionRate;
	}
}
