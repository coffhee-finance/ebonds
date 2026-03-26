// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IERC3475 {
    /**
     * @notice Transfers bonds from one address to another.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 classId,
        uint256 nonce,
        uint256 amount
    ) external;

    /**
     * @notice Checks the balance of a specific bond class and nonce for an owner.
     */
    function balanceOf(
        address owner,
        uint256 classId,
        uint256 nonce
    ) external view returns (uint256);
}

contract Cappucino is ERC1155, Ownable, ReentrancyGuard {
    IERC3475 public immutable bondContract;

    // Track which 1155 ID corresponds to which 3475 Bond
    struct BondMapping {
        uint256 classId;
        uint256 nonce;
        uint256 amount;
    }
    mapping(uint256 => BondMapping) public wrappedBonds;
    uint256 public nextTokenId;

    event BondWrapped(address indexed user, uint256 indexed tokenId, uint256 amount);
    event BondUnwrapped(address indexed user, uint256 indexed tokenId, uint256 amount);

    constructor(address _bondContract) 
        ERC1155("https://api.coffhee.io/metadata/{id}.json") 
        Ownable(msg.sender) 
    {
        bondContract = IERC3475(_bondContract);
    }

    /**
     * @notice Wrap an ERC-3475 bond into an ERC-1155 token.
     */
    function wrap(uint256 classId, uint256 nonce, uint256 amount) external nonReentrant {
        // 1. Pull the 3475 bonds into this contract
        bondContract.safeTransferFrom(msg.sender, address(this), classId, nonce, amount);

        // 2. Map the 1155 ID to the 3475 metadata
        uint256 tokenId = nextTokenId++;
        wrappedBonds[tokenId] = BondMapping(classId, nonce, amount);

        // 3. Mint the 1155 receipt
        _mint(msg.sender, tokenId, 1, "");

        emit BondWrapped(msg.sender, tokenId, amount);
    }

    /**
     * @notice Burn the 1155 token to get the original 3475 bonds back.
     */
    function unwrap(uint256 tokenId) external nonReentrant {
        require(balanceOf(msg.sender, tokenId) > 0, "NOT_OWNER");
        
        BondMapping memory bond = wrappedBonds[tokenId];
        
        // 1. Burn the 1155 receipt
        _burn(msg.sender, tokenId, 1);

        // 2. Send the 3475 bonds back to the user
        bondContract.safeTransferFrom(address(this), msg.sender, bond.classId, bond.nonce, bond.amount);

        emit BondUnwrapped(msg.sender, tokenId, bond.amount);
    }
}