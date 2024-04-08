// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./MusicTuneVibe.sol";

contract TuneVibe is ERC1155Holder {
    uint256 marketFee = 250;
    uint256 donationLimit = 0.005 ether;
    IERC1155 music;

    address payable private _owner;

    event Withdrawal(uint amount, uint when);

    event MusicNFTCreated(
        uint256 indexed tokenId,
        uint256 amount,
        uint256 price
    );

    struct MusicNFT {
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        address artirt;
    }

    mapping(uint256 => MusicNFT) private musicItem;

    event BuyMusicNFT(uint256 indexed tokenId, uint256 amount, uint256 price);

    constructor(address _nftContract) {
        music = IERC1155(_nftContract);
    }

    function MakeMusicNFT(
        uint256 _tokenId,
        uint256 _price,
        uint256 _amount
    ) private {
        require(_price >= 0, "Price must be positive");
        require(
            msg.value == marketFee,
            "Your remain money must be at least equal to the listing fee"
        );

        musicItem[_tokenId] = MusicNFT(_tokenId, _amount, _price, msg.sender);

        music.safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            _amount,
            ""
        );

        emit MusicNFTCreated(_tokenId, _amount, _price);
    }
    function getListingFee() public view returns (uint256) {
        return marketFee;
    }

    function buyNFT(uint256 tokenId, uint256 amount) external payable {
        uint256 price = musicItem[tokenId].price;

        uint256 salePrice = price * amount;
        require(musicItem[tokenId].amount >= amount, "ko du nft");
        require(
            msg.value >= salePrice,
            "Needs to be greater or equal to the price."
        );

        music.safeTransferFrom(
            msg.sender,
            musicItem[tokenId].artirt,
            0,
            salePrice,
            ""
        );
        music.safeTransferFrom(msg.sender, address(this), 0, marketFee, "");

        musicItem[tokenId].amount -= amount;

        music.safeTransferFrom(
            address(this),
            msg.sender,
            musicItem[tokenId].tokenId,
            musicItem[tokenId].amount,
            "0x0"
        );

        emit BuyMusicNFT(tokenId, amount, price);
    }

    function reSale(
        uint256 _tokenId,
        uint256 _amount
    ) public payable returns (uint256) {
        music.safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            _amount,
            ""
        );
        musicItem[_tokenId].amount += _amount;

        return _tokenId;
    }

    function MusicByTokenID(
        uint256 tokenId
    ) public view returns (MusicNFT memory) {
        return musicItem[tokenId];
    }

    // function withdraw() public payable {
    //     require(msg.sender == _owner, "You aren't the owner");

    //     emit Withdrawal(address(this).balance, block.timestamp);

    //     _owner.transfer(address(this).balance);
    // }
}
