// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.25;

import "@fhenixprotocol/cofhe-contracts/FHE.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC3475 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 classId,
        uint256 nonce,
        uint256 amount
    ) external;
}

contract Frappucino is ERC1155, Ownable {

    IERC3475 public immutable bondContract;

    // tokenId => user => encrypted balance
    mapping(uint256 => mapping(address => euint32)) private _encryptedBalances;

    constructor(address _bondContract)
        ERC1155("https://api.frappucino.io/metadata/{id}.json")
        Ownable(msg.sender)
    {
        require(_bondContract != address(0), "Invalid bond contract");
        bondContract = IERC3475(_bondContract);
    }

    /**
     * @dev encryptedAmount must be encrypted off-chain via Fhenix SDK
     */
    function wrapBond(
        uint256 classId,
        uint256 nonce,
        uint256 publicAmount,
        uint256 tokenId,
        euint32 encryptedAmount
    ) external {
        require(publicAmount > 0, "Amount must be > 0");

        bondContract.safeTransferFrom(
            msg.sender,
            address(this),
            classId,
            nonce,
            publicAmount
        );

        _encryptedBalances[tokenId][msg.sender] =
            FHE.add(
                _encryptedBalances[tokenId][msg.sender],
                encryptedAmount
            );

        FHE.allow(_encryptedBalances[tokenId][msg.sender], msg.sender);

        _mint(msg.sender, tokenId, publicAmount, "");
    }

    function confidentialTransfer(
        address to,
        uint256 tokenId,
        euint32 encryptedAmount
    ) external {
        require(to != address(0), "Invalid recipient");

        _encryptedBalances[tokenId][msg.sender] =
            FHE.sub(
                _encryptedBalances[tokenId][msg.sender],
                encryptedAmount
            );

        _encryptedBalances[tokenId][to] =
            FHE.add(
                _encryptedBalances[tokenId][to],
                encryptedAmount
            );

        FHE.allow(_encryptedBalances[tokenId][msg.sender], msg.sender);
        FHE.allow(_encryptedBalances[tokenId][to], to);
    }

    function viewEncryptedBalance(
        uint256 tokenId
    ) external view returns (euint32) {
        return _encryptedBalances[tokenId][msg.sender];
    }

    function balanceOf(
        address,
        uint256
    ) public view override returns (uint256) {
        return 0;
    }
}