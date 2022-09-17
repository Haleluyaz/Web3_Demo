// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Reward = (totalSupply / goal) * input

contract SmartFunding {
    uint256 public fundingStage; // 0 = INACTIVE, 1 = ACTIVE, 2 = SUCCESS, 3 = FAIL
    address public tokenAddress;
    uint public goal;
    uint public pool;
    uint public endTimeInDay;

    mapping(address => uint256) public investOf;
    mapping(address => uint256) public rewardOf;
    mapping(address => bool) public claimedOf;

    event Invest(address indexed from, uint256 amount);
    event ClaimReward(address indexed from, uint256 amount);
    event Refund(address indexed from, uint256 amount);

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
        fundingStage = 0;
    }

     modifier whenInvested () {
         require(investOf[msg.sender] == 0, "Already invest");
        _;
    }

     modifier whenInvestedZero () {
         require(msg.value > 0, "Reject amount of invest");
        _;
    }

     modifier whenInvestedNotActiveStage () {
         require(fundingStage == 1, "Stage isn't active");
        _;
    }

     modifier whenInvestedNotSuccess () {
         require(fundingStage == 2, "Stage isn't success");
        _;
    }

     modifier whenNoReward () {
         require(rewardOf[msg.sender] > 0, "No reward");
        _;
    }

     modifier whenClaimed () {
         require(claimedOf[msg.sender] == false, "Already claimed");
        _;
    }

     modifier whenRefundWithNoInvest () {
         require(investOf[msg.sender] > 0, "No invest");
        _;
    }
     modifier whenRefundFailed () {
         require(fundingStage == 3, "Stage isn't fail");
        _;
    }


    function initialize(uint _goal, uint _endTimeInDay) external {
        goal = _goal;
        endTimeInDay = block.timestamp + (_endTimeInDay * 1 days);
        fundingStage = 1;
    }

    function invest () external payable whenInvested whenInvestedZero whenInvestedNotActiveStage {
        uint256 totalSupply = IERC20(tokenAddress).totalSupply();
        uint256 rewardAmount = (totalSupply / goal) * msg.value;

        investOf[msg.sender] = msg.value;
        rewardOf[msg.sender] = rewardAmount;
        pool += msg.value;

        emit Invest(msg.sender, msg.value);
    }

    function claim() external whenClaimed whenNoReward whenInvestedNotSuccess {
        uint256 reward = rewardOf[msg.sender];
        claimedOf[msg.sender] = true;
        rewardOf[msg.sender] = 0;
        IERC20(tokenAddress).transfer(msg.sender, reward);

        emit ClaimReward(msg.sender, reward);
    }

    function refund() external whenRefundWithNoInvest whenRefundFailed {
        uint256 investAmount = investOf[msg.sender];
        investOf[msg.sender] = 0;
        rewardOf[msg.sender] = 0;
        pool -= investAmount;
        
        payable(msg.sender).transfer(investAmount);

        emit Refund(msg.sender, investAmount);
    }
}