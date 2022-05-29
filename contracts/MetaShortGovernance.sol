// SPDX-License-Identifier: None

pragma solidity ^0.8.1;

import "./MetaShort.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MetaShortGovernance is AccessControl {
    struct Advertisement {
        uint256 desiredReactions;
        uint256 desiredComments;
        uint256 thresholdReactions;
        uint256 thresholdComments;
        uint256 tips;
        uint256 totalCalculatedPrice;
        uint256 until;
        uint256 status;
        uint256 actualReactions;
        uint256 actualComments;
        address advertiser;
    }

    event AdvertisementPublished(
        uint256 id,
        uint256 desiredReactions,
        uint256 desiredComments,
        uint256 thresholdReactions,
        uint256 thresholdComments,
        uint256 until,
        uint256 tips,
        uint256 totalCalculatedPrice,
        address advertiser
    );

    mapping(address => uint256) bloggersCurrentAdvertisement;
    bytes32 ADVERTISER_ROLE = keccak256("ADVERTISER_ROLE");
    bytes32 BLOGGER_ROLE = keccak256("BLOGGER_ROLE");
    MetaShort public token;
    uint256 TOKENS_PER_REACTION = 10;
    uint256 TOKENS_PER_COMMENT = 50;
    uint256 STATUS_ADVERTISEMENT_INACTIVE = 0;
    uint256 STATUS_ADVERTISEMENT_ACTIVE = 1;
    uint256 STATUS_ADVERTISEMENT_TAKEN = 2;
    Advertisement[] advertisements;

    constructor(address metaShort) {
        token = MetaShort(metaShort);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        advertisements.push(Advertisement(0,0,0,0,0,0,0,0,0,0,address(0)));
    }

    function registerAdvertiser(address advertiser) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Should be admin");
        grantRole(ADVERTISER_ROLE, advertiser);
    }

    function registerBlogger(address blogger) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Should be admin");
        grantRole(BLOGGER_ROLE, blogger);
    }

    function publishAdvertisement(
        uint256 desiredReactions,
        uint256 desiredComments,
        uint256 thresholdReactions,
        uint256 thresholdComments,
        uint256 until,
        uint256 tips
    ) public {
        require(hasRole(ADVERTISER_ROLE, msg.sender), "You should be advertiser");
        uint256 calculatedPrice = desiredComments * TOKENS_PER_COMMENT +
            desiredReactions * TOKENS_PER_REACTION;
        uint256 totalCalculatedPrice = tips + calculatedPrice;
        Advertisement memory result = Advertisement(
            desiredReactions,
            desiredComments,
            thresholdReactions,
            thresholdComments,
            tips,
            until,
            totalCalculatedPrice,
            STATUS_ADVERTISEMENT_ACTIVE,
            0,
            0,
            msg.sender);
        token.transferFrom(msg.sender, address(this), totalCalculatedPrice);
        advertisements.push(result);
        emit AdvertisementPublished(advertisements.length - 1,  desiredReactions,
            desiredComments,
            thresholdReactions,
            thresholdComments,
            until,
            tips,
            totalCalculatedPrice,
            msg.sender
        );
    }

    function submitAdvertisement(uint256 advertisementId) public {
        require(hasRole(BLOGGER_ROLE, msg.sender), "you should be blogger");
        require(advertisements[advertisementId].status == STATUS_ADVERTISEMENT_ACTIVE, "advertisement should be active");
        uint256 activitiesCost = advertisements[advertisementId].totalCalculatedPrice - advertisements[advertisementId].tips;
        token.transferFrom(msg.sender, address(this), activitiesCost);
        bloggersCurrentAdvertisement[msg.sender] = advertisementId;
        advertisements[advertisementId].status = STATUS_ADVERTISEMENT_TAKEN;
    }

    function requireRewardForAdvertisement(uint256 advertisementId) public {
        require(hasRole(BLOGGER_ROLE, msg.sender), "you should be blogger");
        require(advertisements[advertisementId].status == STATUS_ADVERTISEMENT_TAKEN, "advertisement should be taken");
        require(bloggersCurrentAdvertisement[msg.sender] == advertisementId, "advertisement should be yours");
        require(block.timestamp > advertisements[advertisementId].until, "adverisement should finish");
        Advertisement memory advertisement = advertisements[advertisementId];
        if (
            (advertisement.actualComments < advertisement.thresholdComments) ||
            (advertisement.actualReactions < advertisement.thresholdReactions)
            ) {
                // TODO: think out what to do with tips
            token.transfer(advertisement.advertiser, advertisement.totalCalculatedPrice);
        }
        else {
            uint256 activitiesCost = advertisement.totalCalculatedPrice - advertisement.tips;
            token.burn(activitiesCost);
            token.transfer(msg.sender, advertisement.totalCalculatedPrice);
        }
        bloggersCurrentAdvertisement[msg.sender] = 0;
    }

    function getCurrentActiveAdvertisement(address blogger) public view returns(uint256) {
        return bloggersCurrentAdvertisement[blogger];
    }

    function getAdvertisement(uint256 id) public view returns (Advertisement memory){
        return advertisements[id];
    }

    function sendActivity(uint256 advertisementId, uint256 reactions, uint256 comments) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "should be admin");
        require(advertisements[advertisementId].status == STATUS_ADVERTISEMENT_TAKEN, "should be taken adv");
        advertisements[advertisementId].actualComments += comments;
        advertisements[advertisementId].actualReactions += reactions;
    }
}
