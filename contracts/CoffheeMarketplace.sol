// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CoffheeMarketplace is Ownable, ReentrancyGuard {

    struct Listing {
        address seller;
        address tokenContract;
        uint256 tokenId;
        uint256 amount;
        uint256 pricePerUnit;
        bool active;
    }

    uint256 public nextListingId;

    mapping(uint256 => Listing) public listings;

    event Listed(
        uint256 indexed listingId,
        address indexed seller,
        address indexed tokenContract,
        uint256 tokenId,
        uint256 amount,
        uint256 pricePerUnit
    );

    event Purchased(
        uint256 indexed listingId,
        address indexed buyer,
        uint256 amount
    );

    event Cancelled(uint256 indexed listingId);

    constructor() Ownable(msg.sender) {}

    /* ============================================================= */
    /*                       ADMIN LISTING                           */
    /* ============================================================= */

    /// @notice Only admin (owner) can list bonds
    function list(
        address tokenContract,
        uint256 tokenId,
        uint256 amount,
        uint256 pricePerUnit
    ) external onlyOwner {

        require(amount > 0, "Invalid amount");
        require(pricePerUnit > 0, "Invalid price");

        IERC1155(tokenContract).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId,
            amount,
            ""
        );

        listings[nextListingId] = Listing({
            seller: msg.sender,
            tokenContract: tokenContract,
            tokenId: tokenId,
            amount: amount,
            pricePerUnit: pricePerUnit,
            active: true
        });

        emit Listed(
            nextListingId,
            msg.sender,
            tokenContract,
            tokenId,
            amount,
            pricePerUnit
        );

        nextListingId++;
    }

    /* ============================================================= */
    /*                           BUY                                 */
    /* ============================================================= */

    function buy(
        uint256 listingId,
        uint256 amount
    ) external payable nonReentrant {

        Listing storage listing = listings[listingId];

        require(listing.active, "Not active");
        require(amount > 0, "Invalid amount");
        require(amount <= listing.amount, "Insufficient supply");

        uint256 totalPrice = listing.pricePerUnit * amount;
        require(msg.value == totalPrice, "Incorrect ETH sent");

        listing.amount -= amount;

        if (listing.amount == 0) {
            listing.active = false;
        }

        IERC1155(listing.tokenContract).safeTransferFrom(
            address(this),
            msg.sender,
            listing.tokenId,
            amount,
            ""
        );

        payable(listing.seller).transfer(msg.value);

        emit Purchased(listingId, msg.sender, amount);
    }

    /* ============================================================= */
    /*                          CANCEL                               */
    /* ============================================================= */

    function cancel(uint256 listingId) external onlyOwner {

        Listing storage listing = listings[listingId];

        require(listing.active, "Not active");

        listing.active = false;

        IERC1155(listing.tokenContract).safeTransferFrom(
            address(this),
            listing.seller,
            listing.tokenId,
            listing.amount,
            ""
        );

        emit Cancelled(listingId);
    }

    /* ============================================================= */
    /*                    ERC1155 RECEIVER                           */
    /* ============================================================= */

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}