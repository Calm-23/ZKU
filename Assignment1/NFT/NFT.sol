//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract MerkleNFT is ERC721URIStorage {
    using Counters for Counters.Counter; 
    Counters.Counter private _tokenIds; //for getting serialized TokenIds

    bytes32[] private leaves; //Merkle Tree leaves

    constructor() ERC721("MerkleItem", "ITM") {}

    //This function mints the NFTs of the given name and 
    //description to the given address. 
    function mint(
        address receiver,
        string memory name,
        string memory description
    ) public returns (uint256) {
        _tokenIds.increment();

        uint256 currentTokenId = _tokenIds.current();
        _mint(receiver, currentTokenId);

        string memory tokenURI = getTokenURI(name, description);
        _setTokenURI(currentTokenId, tokenURI);

        //calculating the hash of the message data
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, receiver, currentTokenId, tokenURI));
        //committing the hash to Merkle tree.
        leaves.push(hash);

        return currentTokenId;
    }


    function getTokenURI(string memory name, string memory description)
        private
        pure
        returns (string memory)
    {
        bytes memory dataURI = abi.encodePacked(
            "{",
            bytes.concat(bytes("name:"), bytes(name)),
            ",",
            bytes.concat(bytes("description:"), bytes(description)),
            "}"
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

}