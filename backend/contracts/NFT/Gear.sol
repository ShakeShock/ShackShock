// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../tools/StringTools.sol";

// import "hardhat/console.sol";

abstract contract Gear is ERC721, Ownable {
    using StringTools for string;

    uint256 private _tokenId;

    struct Equipment {
        uint256 amount;
        uint256 price;
    }
    Equipment[] public equipmentAvailability;

    // Index corresponds to equipment type
    string[] private _equipmentURI;

    // Token Id to equipment type
    mapping(uint256 => uint256) _equipment;

    constructor (
        uint[] memory _amount,
        uint[] memory _price,
        string[] memory _uris,
        string memory _name,
        string memory _symbol)
    ERC721(_name, _symbol) {
        for (uint i = 0; i < _amount.length; i++){
           equipmentAvailability.push(
               Equipment({amount: _amount[i], price: _price[i]})
           );
           _equipmentURI.push(_uris[i]);
        }
        _tokenId = 0;
    }

    // Check if player has the requirements to mint this equipment
    // If yes, handle them the equipment
    function mintEquipment(address account ,uint _equipmentType) external payable onlyOwner {
        require(_equipmentType < equipmentAvailability.length, "Invalid equipment type");
        require(
            equipmentAvailability[_equipmentType].amount > 0,
            "No more equipment of this type available for minting"
        );
        require(
            equipmentAvailability[_equipmentType].price <=  msg.value,
            "Insuficient funds for buying this equipment"
        );

        _safeMint(account, _tokenId);
        _equipment[_tokenId] = _equipmentType;

        Equipment storage eq = equipmentAvailability[_equipmentType];
        eq.amount -= 1;
        _tokenId += 1;
    }

    function tokenURI(uint _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "URI query for non existing token");

        uint equipmentType  = _equipment[_tokenId];
        return string(abi.encodePacked(_baseURI(), getEquipmentMetadataLink(equipmentType)));
    }

    // Get's the equipment link given a type
    function getEquipmentMetadataLink(uint _equipmentType) view public returns (string memory) {
        return _equipmentURI[_equipmentType];
    }

    // Add a new equipment, returns the equpment type
    function addNewEquipment(uint256 _amount, uint256 _price, string memory _uri)
    external onlyOwner returns (uint) {
        require(!_uri.empty(), "Equipment uri cannot be empty");

        equipmentAvailability.push(
            Equipment({
                amount:_amount,
                price:_price
        }));
        _equipmentURI.push(_uri);

        return equipmentAvailability.length;
    }

    // Re-write an existing equipment
    function setEquipmentNewUri(uint _equipmentType, string memory _uri) external onlyOwner {
        _equipmentURI[_equipmentType] = _uri;
    }

    function setEquipmentAvailability(uint _equipmentType, uint _amount, uint _price)
    external onlyOwner {
        Equipment storage e = equipmentAvailability[_equipmentType];
        e.amount = _amount;
        e.price = _price;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }
}
