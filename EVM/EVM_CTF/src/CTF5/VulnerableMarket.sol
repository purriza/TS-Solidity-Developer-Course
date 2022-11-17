// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ThreeSigmaNFT is ERC721, Ownable {
    constructor() ERC721("ThreeSigmaNFT", "TSNFT") {
        _setApprovalForAll(address(this), msg.sender, true);
    }

    function mint(address to, uint256 tokenId) external onlyOwner {
        _mint(to, tokenId);
    }
}

contract ThreeSigmaToken is ERC20 {
    bool airdropped;

    constructor() ERC20("ThreeSigmaToken", "TST") {
        _mint(address(this), 100000000000);
        _mint(msg.sender, 1337);
    }

    function airdrop() external {
        require(!airdropped, "Already airdropped");
        airdropped = true;
        _mint(msg.sender, 5);
    }
}

struct Order {
    address nftAddress;
    uint256 tokenId;
    uint256 price;
}

struct Coupon {
    uint256 orderId;
    uint256 newprice;
    address issuer;
    address user;
    bytes reason;
}

struct Signature {
    uint8 v;
    bytes32[2] rs;
}

struct SignedCoupon {
    Coupon coupon;
    Signature signature;
}

contract VulnerableMarket {
    event SendFlag();
    event NFTListed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);

    event NFTCanceled(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);

    event NFTBought(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 price);

    bool tested;
    ThreeSigmaNFT public tsNFT;
    ThreeSigmaToken public tsToken;
    CouponVerifierBeta public verifier;
    Order[] orders;

    constructor() {
        tsToken = new ThreeSigmaToken();
        tsToken.approve(address(this), type(uint256).max);

        tsNFT = new ThreeSigmaNFT();
        tsNFT.mint(address(this), 1);
        tsNFT.mint(address(this), 2);
        tsNFT.mint(address(this), 3);

        verifier = new CouponVerifierBeta();

        orders.push(Order(address(tsNFT), 1, 1)); // Buy it?
        orders.push(Order(address(tsNFT), 2, 1337)); // 1337 == Amount of ERC20 tokens of the contract (Steal the tokens, the market has to buy it for us) -> purchaseTest
        orders.push(Order(address(tsNFT), 3, 13333333337)); // 13333333337 -> We need to change the price -> purchaseWithCoupon 
        // 0.8.15 Specific bug here -> Fixed 0.8.16
    }

    function getOrder(uint256 orderId) public view returns (Order memory order) {
        require(orderId < orders.length, "Invalid orderId");
        order = orders[orderId];
    }

    function createOrder(address nftAddress, uint256 tokenId, uint256 price) external returns (uint256) {
        require(price > 0, "Invalid price");
        require(isNFTApprovedOrOwner(nftAddress, msg.sender, tokenId), "Not owner");
        orders.push(Order(nftAddress, tokenId, price));
        emit NFTListed(msg.sender, nftAddress, tokenId, price);
        return orders.length - 1;
    }

    function cancelOrder(uint256 orderId) external {
        Order memory order = getOrder(orderId);
        require(isNFTApprovedOrOwner(order.nftAddress, msg.sender, order.tokenId), "Not owner");
        _deleteOrder(orderId);
        emit NFTCanceled(msg.sender, order.nftAddress, order.tokenId);
    }

    function purchaseOrder(uint256 orderId) external {
        Order memory order = getOrder(orderId);
        _deleteOrder(orderId);
        IERC721 nft = IERC721(order.nftAddress);
        address owner = nft.ownerOf(order.tokenId);
        tsToken.transferFrom(msg.sender, owner, order.price);
        nft.safeTransferFrom(owner, msg.sender, order.tokenId);
        emit NFTBought(msg.sender, order.nftAddress, order.tokenId, order.price);
    }

    function purchaseWithCoupon(SignedCoupon calldata scoupon) external {
        Coupon memory coupon = scoupon.coupon;
        require(coupon.user == msg.sender, "Invalid user");
        require(coupon.newprice > 0, "Invalid price");
        verifier.verifyCoupon(scoupon);
        Order memory order = getOrder(coupon.orderId);
        _deleteOrder(coupon.orderId);
        IERC721 nft = IERC721(order.nftAddress);
        address owner = nft.ownerOf(order.tokenId);
        tsToken.transferFrom(coupon.user, owner, coupon.newprice);
        nft.safeTransferFrom(owner, coupon.user, order.tokenId);
        emit NFTBought(coupon.user, order.nftAddress, order.tokenId, coupon.newprice);
    }

    function purchaseTest(address nftAddress, uint256 tokenId, uint256 price) external {
        require(!tested, "Tested");
        tested = true;
        IERC721 nft = IERC721(nftAddress);
        // Calling createOrder "externally", msg.sender = VulnerableMarket
        uint256 orderId = VulnerableMarket(this).createOrder(nftAddress, tokenId, price);
        // It calls approve on the nftAddress, which is passed as argument
        nft.approve(address(this), tokenId);
        // Calling purchaseOrder "externally", msg.sender = VulnerableMarket
        VulnerableMarket(this).purchaseOrder(orderId);
    }

    function win() external {
        require(
            tsNFT.ownerOf(1) == msg.sender && tsNFT.ownerOf(2) == msg.sender && tsNFT.ownerOf(3) == msg.sender
        );
        emit SendFlag();
    }

    function isNFTApprovedOrOwner(address nftAddress, address spender, uint256 tokenId) internal view returns (bool) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        return (spender == owner || nft.isApprovedForAll(owner, spender) || nft.getApproved(tokenId) == spender);
    }

    function _deleteOrder(uint256 orderId) internal {
        // It change the order of Orders whenever an order is deleted
        // Initial order: 1 - 2 - 3
        // Delete order 1
        // Final order: 3 - 2
        orders[orderId] = orders[orders.length - 1];
        orders.pop();
    }

    function onERC721Received(address, address, uint256, bytes memory) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

contract CouponVerifierBeta {
    VulnerableMarket market;
    bool tested;

    constructor() {
        market = VulnerableMarket(msg.sender);
    }

    function verifyCoupon(SignedCoupon calldata scoupon) public {
        require(!tested, "Tested");
        tested = true;
        Coupon memory coupon = scoupon.coupon;
        Signature memory sig = scoupon.signature;
        Order memory order = market.getOrder(coupon.orderId);
        bytes memory serialized = abi.encode(
            "I, the issuer",
            coupon.issuer,
            "offer a special discount for",
            coupon.user,
            "to buy",
            order,
            "at",
            coupon.newprice,
            "because",
            coupon.reason
        );
        IERC721 nft = IERC721(order.nftAddress);
        address owner = nft.ownerOf(order.tokenId);
        require(coupon.issuer == owner, "Invalid issuer");
        require(ecrecover(keccak256(serialized), sig.v, sig.rs[0], sig.rs[1]) == coupon.issuer, "Invalid signature");
    }
}