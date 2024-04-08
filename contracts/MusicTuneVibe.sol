// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MusicTuneVibe is ERC1155, Ownable {
    string[] public tokens;
    string IPFS_PATH;
    address private _owner;

    mapping(string => bool) _tokenExists;

    struct Music {
        uint256 tokenId;
        string uri;
    }

    mapping(uint256 => Music) private musics;

    constructor(
        string memory _ipfs,
        address payable owner
    ) ERC1155("") Ownable(owner) {
        IPFS_PATH = _ipfs;
        _owner = msg.sender;
    }

    function setIPFS(string memory _uri) public onlyOwner {
        IPFS_PATH = _uri;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        // require(_exists(tokenId), "URI query for nonexistent token");
        return string(abi.encodePacked(IPFS_PATH, musics[tokenId].uri));
    }

    function safeMint(string memory _token, uint256 amount) public {
        require(!_tokenExists[_token], "The token URI should be unique");

        tokens.push(_token);
        uint256 _id = tokens.length;
        _mint(msg.sender, _id, amount, "");
        musics[_id] = Music(_id, _token);
        _tokenExists[_token] = true;
    }

    function music(
        uint256 _tokenId
    ) public view returns (Music memory) {
        return musics[_tokenId];
    }
}
