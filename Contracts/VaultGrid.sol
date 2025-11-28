// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title VaultGrid
 * @notice Decentralized Asset Vault with Time-Locked Withdrawals
 * @dev Users deposit ERC-20 tokens which are locked until unlock time.
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VaultGrid is ReentrancyGuard, Ownable {
    IERC20 public token;

    struct Deposit {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => Deposit[]) public userDeposits;

    event Deposited(address indexed user, uint256 amount, uint256 unlockTime, uint256 depositIndex);
    event Withdrawn(address indexed user, uint256 amount, uint256 depositIndex);

    uint256 public minLockTime = 7 days;
    uint256 public maxLockTime = 365 days;

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
    }

    // -------- Deposit Tokens with Lock --------
    function deposit(uint256 amount, uint256 lockTime) external nonReentrant {
        require(amount > 0, "Amount must be > 0");
        require(lockTime >= minLockTime && lockTime <= maxLockTime, "Invalid lock time");

        token.transferFrom(msg.sender, address(this), amount);

        userDeposits[msg.sender].push(Deposit({
            amount: amount,
            unlockTime: block.timestamp + lockTime
        }));

        emit Deposited(msg.sender, amount, block.timestamp + lockTime, userDeposits[msg.sender].length - 1);
    }

    // -------- Withdraw Attempt --------
    function withdraw(uint256 index) external nonReentrant {
        require(index < userDeposits[msg.sender].length, "Invalid index");

        Deposit storage dep = userDeposits[msg.sender][index];
        require(dep.amount > 0, "Already withdrawn");
        require(block.timestamp >= dep.unlockTime, "Funds are still locked");

        uint256 amt = dep.amount;
        dep.amount = 0;

        token.transfer(msg.sender, amt);
        emit Withdrawn(msg.sender, amt, index);
    }

    // -------- Admin Controls --------
    function updateMinLockTime(uint256 newMin) external onlyOwner {
        minLockTime = newMin;
    }

    function updateMaxLockTime(uint256 newMax) external onlyOwner {
        maxLockTime = newMax;
    }

    // -------- Emergency Owner Withdraw (Vault Cleanup) --------
    function adminEmergencyWithdraw(uint256 amount) external onlyOwner {
        token.transfer(owner(), amount);
    }

    // -------- Get User Deposit Count --------
    function getDepositCount(address user) external view returns (uint256) {
        return userDeposits[user].length;
    }

    // -------- Get Single Deposit --------
    function getDeposit(address user, uint256 index) external view returns (uint256 amount, uint256 unlockTime) {
        require(index < userDeposits[user].length, "Invalid index");
        Deposit memory d = userDeposits[user][index];
        return (d.amount, d.unlockTime);
    }
}
