/*
This file is part of the DAO.

The DAO is free software: you can redistribute it and/or modify
it under the terms of the GNU lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The DAO is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the DAO.  If not, see <http://www.gnu.org/licenses/>.
*/


/*
Basic account, used by the DAO contract to separately manage both the rewards
and the extraBalance accounts.
*/

contract ManagedAccountInterface {

    // 该账户的拥有者，该拥有者具有从账户中取钱的权利
    // The only address with permission to withdraw from this account
    address public owner;

    // 如果payOwenerOnly为真，则只有该账户的拥有者可以接收从该账户转出的钱
    // If true, only the owner of the account can receive ether from it
    bool public payOwnerOnly;

    //该智能合约陆续接收到的以太坊的总值
    // The sum of ether (in wei) which has been sent to this contract
    uint public accumulatedInput;

    // 向某个账户发送一定数量的以太币
    /// @notice Sends `_amount` of wei to _recipient
    /// @param _amount The amount of wei to send to `_recipient`
    /// @param _recipient The address to receive `_amount` of wei
    /// @return True if the send completed
    function payOut(address _recipient, uint _amount) returns (bool);

    event PayOut(address indexed _recipient, uint _amount);
}


contract ManagedAccount is ManagedAccountInterface{

    // 构造函数
    // The constructor sets the owner of the account
    function ManagedAccount(address _owner, bool _payOwnerOnly) {
        owner = _owner;
        payOwnerOnly = _payOwnerOnly;
    }

    // 如果该智能合约接收到一个不带数据的交易，则将该交易的以太币数量加入到accumulatedInput中
    // When the contract receives a transaction without data this is called.
    // It counts the amount of ether it receives and stores it in
    // accumulatedInput.
    function() {
        accumulatedInput += msg.value;
    }

    // 向某个账户发送一定数量的以太币
    function payOut(address _recipient, uint _amount) returns (bool) {
        // 1. 只有该合约的拥有者可以调用该函数
        // 2. 调用该函数的交易不能带以太币
        // 3. 如果规定只有合约拥有者才可以接收该账户转出的以太币，则接收者必须是合约拥有者
        if (msg.sender != owner || msg.value > 0 || (payOwnerOnly && _recipient != owner))
            throw;
        if (_recipient.call.value(_amount)()) {
            PayOut(_recipient, _amount);
            return true;
        } else {
            return false;
        }
    }
}
