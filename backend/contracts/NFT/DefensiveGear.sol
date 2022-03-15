// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Gear.sol";

contract DefensiveGear is Gear {
     constructor (uint[] memory _amount, uint[] memory _price, string[] memory _uris)
     Gear(_amount, _price, _uris, "Defensive Gear", "DFGR") {}
}
