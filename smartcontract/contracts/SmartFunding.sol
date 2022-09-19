// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

// Reward = (totalSupply / goal) * input

contract SmartFunding is KeeperCompatibleInterface, Ownable, Pausable {
    uint256 public fundingStage; // 0 = INACTIVE, 1 = ACTIVE, 2 = SUCCESS, 3 = FAIL
    address public tokenAddress;
    uint public goal;
    uint public pool;
    uint public endTime;
    address upkeepAddress;

    mapping(address => uint256) public investOf;
    mapping(address => uint256) public rewardOf;
    mapping(address => bool) public claimedOf;

    event Invest(address indexed from, uint256 amount);
    event ClaimReward(address indexed from, uint256 amount);
    event Refund(address indexed from, uint256 amount);

    constructor(address _tokenAddress, address _upkeepAddress) {
        tokenAddress = _tokenAddress;
        upkeepAddress = _upkeepAddress;
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

     modifier atStage (uint stage) {
         require(fundingStage == stage, "Stage is wrong");
        _;
    }

    function initialize(uint _goal, uint _endTime) external onlyOwner {
        goal = _goal;
        endTime = block.timestamp + (_endTime * 1 days);
        fundingStage = 1;
    }

    function calculateReward (uint amount) public view returns (uint) {
        uint totalPool = pool + amount;
        uint256 totalSupply = IERC20(tokenAddress).totalSupply();

        if(totalPool <= goal) {
            return (totalSupply / goal) * amount;
        } else {
             return (totalSupply / goal) * (goal - pool);
        }
    }

    function invest () external payable whenInvested whenInvestedZero atStage(1) whenNotPaused {
        uint256 rewardAmount = calculateReward(msg.value);

        investOf[msg.sender] = msg.value;
        rewardOf[msg.sender] = rewardAmount;
        pool += msg.value;

        emit Invest(msg.sender, msg.value);
    }

    function claim() external whenClaimed whenNoReward atStage(2) whenNotPaused {
        uint256 reward = rewardOf[msg.sender];
        claimedOf[msg.sender] = true;
        rewardOf[msg.sender] = 0;
        IERC20(tokenAddress).transfer(msg.sender, reward);

        emit ClaimReward(msg.sender, reward);
    }

    function refund() external whenRefundWithNoInvest atStage(3) whenNotPaused {
        uint256 investAmount = investOf[msg.sender];
        investOf[msg.sender] = 0;
        rewardOf[msg.sender] = 0;
        pool -= investAmount;
        
        payable(msg.sender).transfer(investAmount);

        emit Refund(msg.sender, investAmount);
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = fundingStage == 1 && block.timestamp >= endTime;
        performData = new bytes(0);
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        require(msg.sender == upkeepAddress, "Permission denied");

        if (pool >= goal) {
            fundingStage = 2;  
        } else {
            fundingStage = 3;
        }
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}