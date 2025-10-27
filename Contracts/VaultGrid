// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title VaultGrid
 * @dev A decentralized vault system for secure asset storage with time-locked withdrawals
 */
contract VaultGrid {
    
    struct Vault {
        uint256 balance;
        uint256 lockTime;
        bool exists;
    }
    
    mapping(address => Vault) private vaults;
    
    event VaultCreated(address indexed owner, uint256 amount, uint256 lockTime);
    event Deposited(address indexed owner, uint256 amount);
    event Withdrawn(address indexed owner, uint256 amount);
    
    /**
     * @dev Creates a new vault with initial deposit and lock time
     * @param _lockDuration Duration in seconds for which funds will be locked
     */
    function createVault(uint256 _lockDuration) external payable {
        require(msg.value > 0, "Must deposit funds to create vault");
        require(!vaults[msg.sender].exists, "Vault already exists");
        require(_lockDuration > 0, "Lock duration must be greater than 0");
        
        vaults[msg.sender] = Vault({
            balance: msg.value,
            lockTime: block.timestamp + _lockDuration,
            exists: true
        });
        
        emit VaultCreated(msg.sender, msg.value, block.timestamp + _lockDuration);
    }
    
    /**
     * @dev Deposits additional funds into an existing vault
     */
    function deposit() external payable {
        require(vaults[msg.sender].exists, "Vault does not exist");
        require(msg.value > 0, "Must deposit a positive amount");
        
        vaults[msg.sender].balance += msg.value;
        
        emit Deposited(msg.sender, msg.value);
    }
    
    /**
     * @dev Withdraws funds from vault after lock time has expired
     * @param _amount Amount to withdraw from the vault
     */
    function withdraw(uint256 _amount) external {
        require(vaults[msg.sender].exists, "Vault does not exist");
        require(block.timestamp >= vaults[msg.sender].lockTime, "Vault is still locked");
        require(_amount > 0, "Withdrawal amount must be greater than 0");
        require(vaults[msg.sender].balance >= _amount, "Insufficient vault balance");
        
        vaults[msg.sender].balance -= _amount;
        
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawn(msg.sender, _amount);
    }
    
    /**
     * @dev Returns vault information for the caller
     * @return balance Current balance in the vault
     * @return lockTime Timestamp when vault unlocks
     * @return isLocked Whether the vault is currently locked
     */
    function getVaultInfo() external view returns (uint256 balance, uint256 lockTime, bool isLocked) {
        require(vaults[msg.sender].exists, "Vault does not exist");
        
        Vault memory vault = vaults[msg.sender];
        return (
            vault.balance,
            vault.lockTime,
            block.timestamp < vault.lockTime
        );
    }
}
