// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract ubONE is ERC20PresetMinterPauser, Ownable {
    
    constructor(uint256 initialSupply) ERC20PresetMinterPauser("ubONE", "UNE") {
        _mint(msg.sender, initialSupply);
    }

    /// @dev Return `true` if the `account` belongs to the community.
    function isMember(address account) public virtual view returns (bool)
    {
        return hasRole(MINTER_ROLE, account);
    }

    /// @dev Add a member of the community.
    function addMember(address account) public virtual onlyOwner {
        _setupRole(MINTER_ROLE, account);
    }

}