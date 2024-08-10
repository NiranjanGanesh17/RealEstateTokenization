// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CoinContract is ERC20 {
    constructor() ERC20("real_coin", "REAL_COIN") {
    }

    function mintToken(address to, uint256 amount) external {
         _mint(to, amount);
    }
     function transferToken(address from,address to, uint256 amount) external {
         transferFrom(from, to, amount);
    }
}