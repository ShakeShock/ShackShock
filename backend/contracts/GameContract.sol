// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Escrow.sol";
import "./ShakeToken.sol";
import "./NFT/NFTMinting.sol";
import "./NFT/Gear.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameContract is Ownable {
    Escrow public escrow;
    ShakeToken public token;
    NFTMinting public nftCharacter;
    Gear public nftOffGear;
    Gear public nftDefGear;

    uint public constant tokensPerNft = 10000 * 10**18; // 10 000 token for every nft

    constructor(
        address _escrow,
        address _token,
        address _nftMinting,
        address _nftDef,
        address _nftOff
    ) {
        escrow = Escrow(_escrow);
        token = ShakeToken(_token);
        nftCharacter = NFTMinting(_nftMinting);

        nftDefGear = Gear(_nftDef);
        nftOffGear = Gear(_nftOff);
    }

    function mintNftCharacter(uint8 _shakerType) public {
        nftCharacter.mintShaker(msg.sender, _shakerType);
        mintTokens();
    }

    function mintNftOffGear(uint _equipmentType) public {
        nftOffGear.mintEquipment(msg.sender, _equipmentType);
    }

    function mintNftDefGear(uint _equipmentType) public {
        nftDefGear.mintEquipment(msg.sender, _equipmentType);
    }

    function mintTokens() private onlyOwner {
        // This contract will have to be a MINTER ROLE in ShakeToken.
        token.mint(msg.sender, tokensPerNft);
    }

    function levelUpCharacter(uint _tokenId, uint16 _currentLevel) public onlyOwner {
        nftCharacter.levelUpShaker(_tokenId, _currentLevel + 1);
    }

    function improveCivilization(uint _tokenId, uint8 _newCivilization) public onlyOwner {
        nftCharacter.levelUpShaker(_tokenId, 0);
        nftCharacter.changeShakerCivilization(_tokenId, _newCivilization);
    }

    function startGame(
        // The ownership of the escrow contract will have to be transfered to this contract
        // Before calling this function the players will have to approve escrow account so it can transferFrom
        address _p1,
        address _p2,
        uint _amount
    ) public onlyOwner {
        require(_p1 != address(0) && _p2 != address(0));
        require(_amount != 0, "Amount can't be 0");

        escrow.startGame(_p1, _p2, _amount);
    }

    function endGame(
        address _p1,
        address _p2,
        address winner
    ) public onlyOwner {
        escrow.payOutWinner(_p1, _p2, winner);
    }
}
