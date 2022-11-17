// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

import "forge-std/Test.sol";

import "../src/CTF5/VulnerableMarket.sol";
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

    function setUp() public {
        vm.startPrank(player);

        vulnerableMarket = new VulnerableMarket();
        attacker = new Attacker(address(vulnerableMarket));

        pvk = 12345678945613;
        // We have to get the attacker from the pvk
        attacker_1 = vm.addr(pvk);

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