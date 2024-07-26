// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
// Creating some mock tokesn because we wanna test them 
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    // Name of the token would be Mock and symbol be MOCK
    constructor () ERC20("Mock", "MOCK"){  
    }
    function mint(address to , uint256 amount) public{
        _mint(to , amount);
    }
}