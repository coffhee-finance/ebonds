// contracts/mocks/MockERC3475.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract MockERC3475 {

    mapping(address => uint256) public balances;

    function mint(address to, uint256 amount) external {
        balances[to] += amount;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256,
        uint256,
        uint256 amount
    ) external {
        require(balances[from] >= amount, "Insufficient balance");
        balances[from] -= amount;
        balances[to] += amount;
    }
}