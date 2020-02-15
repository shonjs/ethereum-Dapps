pragma solidity ^0.5.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WETHInterface is IERC20 {
    function deposit() public payable;

    function withdraw(uint256 amount) public;
}
