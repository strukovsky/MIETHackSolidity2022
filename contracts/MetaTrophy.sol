// SPDX-License-Identifier: None

pragma solidity ^0.8.1;

import "./MetaShort.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MetaTrophy is ERC721URIStorage, Ownable {

    uint256 counter = 0;
    constructor () ERC721 ("MetaTrophey", "MTROPH") {

    }

    event TropheyMinted(uint256 tokenId);

    function createCollectible(address to, string memory tokenURI) onlyOwner public {
        _safeMint(to, counter);
        _setTokenURI(counter, tokenURI);
        counter++;
        emit TropheyMinted(counter);
    }

    
}