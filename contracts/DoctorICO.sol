pragma solidity ^0.8.17;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DoctorICO is Ownable {
    address Doctor;

    uint256 public constant CAP = 5000 ether; // Cap in bnb
    uint256 public constant FIRST_RATE = 500; // Number of tokens per Bnb at first step
    uint256 public constant SECOND_RATE = 400; // Number of tokens per Bnb at second step
    uint256 public constant THIRD_RATE = 300; // Number of tokens per Bnb at third step
    uint256 public START; // start date of ICO
    uint256 public FIRST_DAYS;  // end date of first step
    uint256 public SECOND_DAYS; // end date of second step
    uint256 public THIRD_DAYS; // end date of third step

    uint16 public airdropReferRate = 100; //10%
    uint16 public buyReferRate = 100; //10%
    uint256 public airdropFee = 0.01 ether;
    uint256 public airdropAmount = 10000 ether;
    uint256 public minBuyAmount = 100 ether; //at least have to buy 100 token per once

    uint256 public constant initialTokens = 2000000 * 10**18; // Initial number of tokens available
    bool public initialized = false;
    uint256 public raisedAmount = 0;

    event BoughtTokens(address indexed to, uint256 value);
    event UsedReferLink(address indexed to, uint256 value);

    modifier whenSaleIsActive() {
        // Check if sale is active
        require(isActive(), "Sale is not active now!");
        _;
    }

    constructor(uint256 _START, uint8 first, uint8 second, uint8 third) {
        START = _START;
        FIRST_DAYS = START + first * 1 days;
        SECOND_DAYS = FIRST_DAYS + second * 1 days;
        THIRD_DAYS = SECOND_DAYS + third * 1 days;
    }

    function setToken(address _tokenAddr) public onlyOwner {
        Doctor = _tokenAddr;
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
            block.timestamp <= THIRD_DAYS && // Must be before the end date
            goalReached() == false); // Goal must not already be reached
    }

    function getICOPrice() public view returns (uint256) {
        uint256 rate;
        if (block.timestamp <= FIRST_DAYS) rate = FIRST_RATE;
        if (block.timestamp <= SECOND_DAYS && block.timestamp > FIRST_DAYS) return rate = SECOND_RATE;
        if (block.timestamp <= THIRD_DAYS && block.timestamp > SECOND_DAYS) return rate = THIRD_RATE;
        return rate;
    }

    function goalReached() public view returns (bool) {
        return raisedAmount >= CAP;
    }

    function airDrop(address _refer) public payable {
        require(msg.value == airdropFee, "Not enough fee!");
        IERC20(Doctor).transfer(msg.sender, airdropAmount);
        if (_refer != msg.sender && _refer != address(0)) {
            IERC20(Doctor).transfer(
                _refer,
                (airdropReferRate * airdropAmount) / 1000
            );
        }
        payable(owner()).transfer(msg.value); // Send money to owner
    }

    function buyTokens(address _refer) public payable whenSaleIsActive {
        uint256 RATE = getICOPrice();
        require(
            msg.value * RATE >= minBuyAmount,
            "Have to buy more than minimum amount."
        );
        uint256 buyAmount = msg.value * RATE;
        emit BoughtTokens(msg.sender, buyAmount); // log event onto the blockchain
        raisedAmount += msg.value; // Increment raised amount
        IERC20(Doctor).transfer(
            msg.sender,
            buyAmount
        ); // Send tokens to refer
        if (_refer != msg.sender && _refer != address(0)) {
            uint256 referAmount = (buyAmount * buyReferRate) / 1000;
            IERC20(Doctor).transfer(msg.sender, referAmount); // Send tokens to buyer
            emit UsedReferLink(_refer, referAmount);
        }
        payable(owner()).transfer(msg.value); // Send money to owner
    }

    function setAirdropParam(uint16 _airdropReferRate, uint256 _airdropFee, uint256 _airdropAmount) public onlyOwner{
        airdropReferRate = _airdropReferRate;
        airdropFee = _airdropFee;
        airdropAmount = _airdropAmount;
    }

    function setBuyParam(uint16 _buyReferRate, uint256 _minBuyAmount) public onlyOwner {
        buyReferRate = _buyReferRate;
        minBuyAmount = _minBuyAmount;
    }

    function tokensAvailable() public view returns (uint256) {
        return IERC20(Doctor).balanceOf(address(this));
    }

    function destroy() public onlyOwner {
        // Transfer tokens back to owner
        uint256 restAmount = tokensAvailable();
        if (restAmount > 0) {
            IERC20(Doctor).transfer(owner(), restAmount);
        }
        selfdestruct(payable(owner()));
    }
}
