// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

contract MusicTuneVibe is ERC1155, Ownable {
    string[] public tokens;
    string IPFS_PATH;
    address private _owner;
    uint256 marketFee = 0 ether;

    mapping(string => bool) _tokenExists;

    event Withdrawal(uint amount, uint when);

    event MusicNFTCreated(
        uint256 indexed tokenId,
        string uri,
        uint256 amount,
        uint256 price,
        address artirt
    );

    struct Music {
        uint256 tokenId;
        string uri;
        uint256 amount;
        uint256 price;
        address artirt;
    }

    event BuyMusicNFT(uint256 indexed tokenId, uint256 amount, uint256 price);

    mapping(uint256 => Music) private musics;

    constructor(string memory _ipfs) ERC1155("") Ownable() {
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

    function safeMint(
        string memory _token,
        uint256 _amount,
        uint256 _price
    ) public payable {
        require(!_tokenExists[_token], "The token URI should be unique");
        require(_price > 0, "Price must be positive");
        require(msg.value == marketFee, "Your remain money not allow");

        payable(address(0)).transfer(msg.value);

        tokens.push(_token);
        uint256 _id = tokens.length;
        _mint(address(this), _id, _amount, "");
        musics[_id] = Music(_id, _token, _amount, _price, msg.sender);
        _tokenExists[_token] = true;

        emit MusicNFTCreated(_id, _token, _amount, _price, address(msg.sender));
    }

    function music(uint256 _tokenId) public view returns (Music memory) {
        return musics[_tokenId];
    }
    function memcmp(
        bytes memory a,
        bytes memory b
    ) internal pure returns (bool) {
        return (a.length == b.length) && (keccak256(a) == keccak256(b));
    }

    function tokenByHash(
        string memory _hash
    ) public view returns (Music memory) {
        require(_tokenExists[_hash], "The token URI should be mint");

        for (uint256 i = 0; i < tokens.length; i++) {
            if (memcmp(bytes(musics[i + 1].uri), bytes(_hash))) {
                return musics[i + 1];
            }
        }
        Music memory emptyPropertyObj;
        return emptyPropertyObj;
    }

    function getListingFee() public view returns (uint256) {
        return marketFee;
    }

    function buyNFT(uint256 tokenId, uint256 amount) public payable {
        uint256 price = musics[tokenId].price;

        uint256 salePrice = price * amount;
        require(musics[tokenId].amount >= amount, "ko du nft");
        require(
            msg.value == salePrice,
            "Needs to be greater or equal to the price."
        );

        payable(musics[tokenId].artirt).transfer(salePrice);
        musics[tokenId].amount -= amount;

        onERC1155Received(msg.sender, address(this), tokenId, amount, "");
        safeTransferFrom(
            address(this),
            msg.sender,
            musics[tokenId].tokenId,
            musics[tokenId].amount,
            "0x0"
        );

        emit BuyMusicNFT(tokenId, amount, price);
    }
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }
    function reSale(
        uint256 _tokenId,
        uint256 _amount
    ) public payable returns (uint256) {
        safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "");
        musics[_tokenId].amount += _amount;

        return _tokenId;
    }
}
