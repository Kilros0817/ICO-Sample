pragma solidity ^0.8.17;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Espadlife is ERC20, Ownable {
    uint16 private _burnPercent = 1; //0.1% auto burn
    uint16 private _maxTxPercent = 500; //50%
    uint256 public constant ICOEND = 1670544000; // December 9, 2022


    constructor(uint256 _totalSupply) ERC20("ESPADLIFE", "ESP") {
        _mint(address(this), _totalSupply);
    }

    function _transfer(
        address sender,
        address receiver,
        uint256 amount
    ) internal override {
        require(
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

    function burn(uint256 amount) public onlyOwner {
        _burn(address(this), amount);
    }

    function airdrop(uint256 amount, address receiver) public onlyOwner {
        require(block.timestamp >= ICOEND, "Still on ICO.");
        transfer(receiver, amount);
    }
}
