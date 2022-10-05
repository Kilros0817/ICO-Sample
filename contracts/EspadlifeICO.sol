pragma solidity ^0.8.17;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EspadlifeICO is Ownable {
    address Espadlife;

    uint256 public constant RATE = 300; // Number of tokens per Bnb
    uint256 public constant CAP = 5000 ether; // Cap in bnb
    uint256 public constant START = 1665360000; // October 10, 2022
    uint256 public constant DAYS = 60 days;

    uint256 public constant initialTokens = 2000000 * 10**18; // Initial number of tokens available
    bool public initialized = false;
    uint256 public raisedAmount = 0;

    event BoughtTokens(address indexed to, uint256 value);

    modifier whenSaleIsActive() {
        // Check if sale is active
        require(isActive(), "Sale is not active now!");
        _;
    }

    function setToken(address _tokenAddr) public onlyOwner {
        Espadlife = _tokenAddr;
    }

    function initialize() public onlyOwner {
        require(initialized == false, "Can only be initialized once.");
        require(
            tokensAvailable() == initialTokens,
            "Must have enough tokens allocated"
        );
        initialized = true;
    }

    function isActive() public view returns (bool) {
        return (initialized == true &&
            block.timestamp >= START && // Must be after the START date
            block.timestamp <= START + DAYS && // Must be before the end date
            goalReached() == false); // Goal must not already be reached
    }

    function goalReached() public view returns (bool) {
        return raisedAmount >= CAP;
    }

    function buyTokens() public payable whenSaleIsActive {
        uint256 buyAmount = msg.value * RATE;
        emit BoughtTokens(msg.sender, buyAmount); // log event onto the blockchain
        raisedAmount += msg.value; // Increment raised amount
        IERC20(Espadlife).transfer(msg.sender, buyAmount); // Send tokens to buyer
        payable(owner()).transfer(msg.value); // Send money to owner
    }

    function tokensAvailable() public view returns (uint256) {
        return IERC20(Espadlife).balanceOf(address(this));
    }

    function destroy() public onlyOwner {
        // Transfer tokens back to owner
        uint256 restAmount = tokensAvailable();
        if (restAmount > 0) {
            IERC20(Espadlife).transfer(owner(), restAmount);
        }
        selfdestruct(payable(owner()));
    }
}
