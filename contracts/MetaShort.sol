//SPDX-License-Identifier: None

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MetaShort is ERC20, ERC20Burnable, AccessControl {

    bytes32 public MINTER_ROLE = keccak256("MINTER_ROLE");
    constructor() ERC20("MetaShort", "MSHRT"){
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}
