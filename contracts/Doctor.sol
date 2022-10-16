pragma solidity ^0.8.17;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Doctor is ERC20, Ownable {
    uint16 private _burnPercent = 1; //0.1% auto burn
    uint16 private _maxTxPercent = 500; //50%

    mapping(address => bool) banList;

    modifier NotOnBlockList(address acc) {
        require(banList[acc] == false, "You are on Ban List!");
        _;
    }

    constructor(uint256 _totalSupply, uint256 _icoAmount) ERC20("Doctor token", "DOT") {
        _mint(address(this), (_totalSupply - _icoAmount) * 10 ** 18);
        _mint(msg.sender, _icoAmount * 10 ** 18);
    }

    function _transfer(
        address sender,
        address receiver,
        uint256 amount
    ) internal override NotOnBlockList(sender) {
        require(
            sender == owner() ||
            balanceOf(sender) >= (amount / _maxTxPercent) * 1000,
            "Exceed max transaction allowance!"
        );
        uint256 burnAmount = (amount * _burnPercent) / 1000;
        _burn(address(this), burnAmount);
        super._transfer(sender, receiver, amount);
    }

    function setBurnPercent(uint16 percent) public onlyOwner {
        _burnPercent = percent;
    }

    function setMaxTxPercent(uint16 maxTxPercent) public onlyOwner {
        _maxTxPercent = maxTxPercent;
    }

    function airdrop(uint256 amount, address receiver) public onlyOwner {
        transfer(receiver, amount);
    }

    function blackList(address holder, bool isBlock) public onlyOwner {
        banList[holder] = isBlock;
    }
}
