// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

/// @title ShakeToken
/// @author ShakeShock
/// @notice Shake ERC20 token used as the in-game currency on chain for ShakeShock
/// inherits from:
///     ERC20Burnable:  to support burning of tokens in order to add a deflationary mechanism to the currency
///     AccessControl:  to introduce roles for privileged actions - a role can have many authorised accounts
///     ERC20Permit:    token holders permit third parties to transfer tokens on their behalf without paying gas (useful for game mechanisms)
///     Pausable:       permitted accounts can pause the contract for security

contract ShakeToken is
    ERC20,
    ERC20Burnable,
    Pausable,
    AccessControl,
    ERC20Permit
{
    /// @notice the role permitted to pause the contract, can have many authorised accounts
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice the role permitted to mint new tokens, can have many authorised accounts
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @dev roles can have many auth accounts, _grantRole needs to called from deployer address in order to append auth accounts
    constructor() ERC20("Shake", "SHAKE") ERC20Permit("Shake") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    /// @notice function that only allows MINTER_ROLE to mint new tokens
    /// @dev limit minting of new tokens to MINTER_ROLE only
    /// @param to The address to transfer minted tokens to
    /// @param amount The amount of new tokens to mint
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /// @notice pauses the contract, only allowed by PAUSER_ROLE
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice unpauses the contract, only allowed by PAUSER_ROLE
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /// @notice this hook is always called before transfers/mints of token, adds a check to ensure contract is not paused
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }
}
