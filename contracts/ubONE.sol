// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol';

contract ubONE is ERC20PresetMinterPauser {
    
    constructor(uint256 initialSupply) ERC20PresetMinterPauser("ubONE", "UNE") {
        _mint(msg.sender, initialSupply);
    }
}