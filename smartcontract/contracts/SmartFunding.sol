// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Reward = (totalSupply / goal) * input

contract SmartFunding {
    address public tokenAddress;
    uint public goal;
    uint public pool;
    uint public endTimeInDay;

    mapping(address => uint256) public investOf;
    mapping(address => uint256) public rewardOf;

    event Invest(address indexed from, uint256 amount);

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }

     modifier whenInvested () {
         require(investOf[msg.sender] == 0, "Already invest");
        _;
    }

     modifier whenInvestedZero () {
         require(msg.value > 0, "Reject amount of invest");
        _;
    }

    function initialize(uint _goal, uint _endTimeInDay) external {
        goal = _goal;
        endTimeInDay = block.timestamp + (_endTimeInDay * 1 days);
    }

    function invest () external payable whenInvested whenInvestedZero{
        uint256 totalSupply = IERC20(tokenAddress).totalSupply();
        uint256 rewardAmount = (totalSupply / goal) * msg.value;

        investOf[msg.sender] = msg.value;
        rewardOf[msg.sender] = rewardAmount;
        pool += msg.value;

        emit Invest(msg.sender, msg.value);
    }
}