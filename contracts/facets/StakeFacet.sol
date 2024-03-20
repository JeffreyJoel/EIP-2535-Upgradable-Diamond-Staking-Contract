// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "../interfaces/IERC20.sol";

contract StakeFacet {
    IERC20 public stakingToken;
    IERC20 public rewardToken;
    uint256 public apy;

    mapping(address => uint256) public stakedAmounts;
    mapping(address => uint256) public rewards;

    constructor(IERC20 _stakingToken, IERC20 _rewardToken, uint256 _apy) {
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
        apy = _apy;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");

        uint256 stakedAmount = stakedAmounts[msg.sender];
        uint256 rewardAmount = calculateReward(stakedAmount);

        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakedAmounts[msg.sender] += amount;
        rewards[msg.sender] += rewardAmount;
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(stakedAmounts[msg.sender] >= amount, "Insufficient staked amount");

        uint256 rewardAmount = calculateReward(stakedAmounts[msg.sender]);

        stakedAmounts[msg.sender] -= amount;
        rewards[msg.sender] += rewardAmount;

        stakingToken.transfer(msg.sender, amount);
        rewardToken.transfer(msg.sender, rewardAmount);
    }

    function calculateReward(uint256 stakedAmount) internal view returns (uint256) {
        uint256 rewardAmount = (stakedAmount * apy) / 100;
        return rewardAmount;
    }
}