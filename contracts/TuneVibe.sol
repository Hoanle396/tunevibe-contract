// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TuneVibe is ERC1155URIStorage, Ownable {
    uint256 private _tokenIdCounts;
    uint256 private listingFee = 0.001 ether;

    address payable private _owner;

    event Withdrawal(uint amount, uint when);

    event MusicNFTCreated(
        uint256 indexed tokenId,
        uint256 amount,
        uint256 price,
        address artirt,
        address owner
    );

    event BuyMusicNFT(uint256 indexed tokenId, uint256 amount, uint256 price);

    struct MusicNFT {
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        address payable artirt;
        address payable owner;
    }

    mapping(uint256 => MusicNFT) private musicItem;

    constructor(address payable owner) Ownable(owner) ERC1155("TuneVibe") {
        _owner = owner;
    }

    function mint(
        string memory tokenURI,
        uint256 amount,
        uint256 price
    ) public payable returns (uint256) {
        require(amount > 0, "Amount must be more than 0");
        require(price >= 0, "Price must be more than 0");
        _tokenIdCounts += 1;

        _mint(msg.sender, _tokenIdCounts, amount, "");
        _setURI(_tokenIdCounts, tokenURI);

        CreatedMusicNFT(_tokenIdCounts, price, amount);

        return _tokenIdCounts;
    }

    function CreatedMusicNFT(
        uint256 _tokenId,
        uint256 _price,
        uint256 _amount
    ) private {
        require(_price >= 0, "Price must be positive");
        require(
            msg.value == listingFee,
            "Your remain money must be at least equal to the listing fee"
        );

        musicItem[_tokenId] = MusicNFT(
            _tokenId,
            _amount,
            _price,
            payable(msg.sender),
            payable(address(this))
        );

        safeTransferFrom(address(this), msg.sender, _tokenId, _amount, "");

        emit MusicNFTCreated(
            _tokenId,
            _amount,
            _price,
            msg.sender,
            address(this)
        );
    }
    function getListingFee() public view returns (uint256) {
        return listingFee;
    }

    function buyNFT(uint256 tokenId, uint256 amount) external payable {
        uint256 price = musicItem[tokenId].price;

        uint256 salePrice = price * amount;
        require(musicItem[tokenId].amount >= amount, "ko du nft");
        require(
            msg.value >= salePrice,
            "Needs to be greater or equal to the price."
        );
        safeTransferFrom(msg.sender, musicItem[tokenId].artirt, 0, price, "");
        safeTransferFrom(msg.sender, address(this), 0, listingFee, "");

        musicItem[tokenId].amount -= amount;

        safeTransferFrom(
            musicItem[tokenId].owner,
            msg.sender,
            musicItem[tokenId].tokenId,
            musicItem[tokenId].amount,
            "0x0"
        );

        emit BuyMusicNFT(tokenId, amount, price);
    }

    function fetchItems() public view returns (MusicNFT[] memory) {
        uint256 currentIndex = 0;

        MusicNFT[] memory items = new MusicNFT[](_tokenIdCounts);
        for (uint256 i = 0; i < _tokenIdCounts; i++) {
            if (musicItem[i + 1].amount > 0) {
                MusicNFT storage currentItem = musicItem[i + 1];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function reSale(
        uint256 _tokenId,
        uint256 _amount
    ) public payable returns (uint256) {
        musicItem[_tokenId].amount += _amount;

        safeTransferFrom(address(this), msg.sender, _tokenId, _amount, "");

        return _tokenId;
    }

    function MusicByTokenID(
        uint256 tokenId
    ) public view returns (MusicNFT memory) {
        return musicItem[tokenId];
    }

    function withdraw() public payable {
        require(msg.sender == _owner, "You aren't the owner");

        emit Withdrawal(address(this).balance, block.timestamp);

        _owner.transfer(address(this).balance);
    }
}
