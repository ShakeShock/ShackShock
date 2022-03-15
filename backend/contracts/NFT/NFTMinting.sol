// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "hardhat/console.sol";
import "../tools/StringTools.sol";

contract NFTMinting is ERC721, Ownable, ReentrancyGuard {
    using StringTools for string;

    uint256 constant MAX_SHAKERS = 1;

    uint256 private _tokenMinted = 0;
    // Pack values in a 32 bit structure
    struct Shaker {
        uint16 level;
        uint8 civilization;
        uint8 class;
    }

    // Structure to have possible amount to mint
    // And its value
    struct ShakerClass {
        uint256 amount;
        uint256 price;
    }
    // Each token class value and amount for minting
    ShakerClass[] public tokenAvailabilty;
    // Token ID to Shaker
    mapping(uint => Shaker) private _shakers;
    // Shaker Properties Hash to URI
    mapping(bytes32 => string) private _metadata;

    event URIChanged(bytes32 indexed);

    constructor(
        uint16[] memory _level,
        uint8[] memory _civilization,
        uint8[] memory _class,
        string[] memory _links,
        ShakerClass[] memory _mintingValues
    ) ERC721("Shaker", "SKR") {
        // Set values for how many times a class can be minted
        // and how much user needs to pay
        for (uint i = 0; i < _mintingValues.length; i++) {
            tokenAvailabilty.push(_mintingValues[i]);
        }

        // Set IPFS location for each shaker type
        for (uint i = 0; i < _level.length; i++) {
            bytes32 shakerHash = getShakerHash(
                _level[i],
                _civilization[i],
                _class[i]
            );
            _metadata[shakerHash] = _links[i];
        }
    }

    function mintShaker(uint8 shakerType, address _caller)
        external
        payable
        nonReentrant
        onlyOwner
    {
        require(shakerType < tokenAvailabilty.length, "Invalid shaker type");

        ShakerClass storage classAvalability = tokenAvailabilty[shakerType];
        require(
            classAvalability.amount > 0,
            "No more minting for type selected"
        );
        require(classAvalability.price <= msg.value, "Insuficient funds");

        classAvalability.amount -= 1;

        _safeMint(_caller, _tokenMinted);
        _shakers[_tokenMinted] = primitiveShaker(shakerType);

        _tokenMinted += 1;
    }

    function tokenURI(uint tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "URI query for non existing token");

        Shaker memory playerShaker = _shakers[tokenId];
        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    getShakerMetadataLink(playerShaker)
                )
            );
    }

    function getShakerMetadataLink(Shaker memory s)
        internal
        view
        returns (string memory)
    {
        return getShakerMetadataLink(s.level, s.civilization, s.class);
    }

    function getShakerMetadataLink(
        uint16 _level,
        uint8 _civilization,
        uint8 _class
    ) public view returns (string memory) {
        bytes32 shakerHash = getShakerHash(_level, _civilization, _class);

        // Need to verifiy if that combination does exists!
        require(
            !_metadata[shakerHash].empty(),
            "Not valid combination of Shaker properties"
        );

        return _metadata[shakerHash];
    }

    function addShakerMetadataLink(
        uint16 _level,
        uint8 _civilization,
        uint8 _class,
        string calldata _link
    ) external onlyOwner validURI(_link) {
        bytes32 shakerHash = getShakerHash(_level, _civilization, _class);
        require(
            !_metadata[shakerHash].empty(),
            "There is already a link for this shaker"
        );

        _metadata[shakerHash] = _link;
        emit URIChanged(shakerHash);
    }

    function overwriteShakerMetadataLink(
        uint16 _level,
        uint8 _civilization,
        uint8 _class,
        string calldata _link
    ) external onlyOwner validURI(_link) {
        bytes32 shakerHash = getShakerHash(_level, _civilization, _class);
        require(
            !_metadata[shakerHash].empty(),
            "There is no link to override for this shaker"
        );

        _metadata[shakerHash] = _link;
        emit URIChanged(shakerHash);
    }

    // Increase shaker level, which means it has a new link in ipfs
    // If invalid level revert
    function levelUpShaker(uint _tokenId, uint16 _level)
        external
        onlyOwner
        hasShaker(_tokenId)
    {
        Shaker storage playerShaker = _shakers[_tokenId];
        playerShaker.level = _level;

        require(
            !getShakerMetadataLink(playerShaker).empty(),
            "Undefined Shaker properties"
        );
    }

    // Change Shaker civilization, (new ipfs link)
    // If cannot change, revert
    function changeShakerCivilization(uint _tokenId, uint8 _civilization)
        external
        onlyOwner
        hasShaker(_tokenId)
    {
        Shaker storage playerShaker = _shakers[_tokenId];
        playerShaker.civilization = _civilization;

        require(
            !getShakerMetadataLink(playerShaker).empty(),
            "Undefined Shaker properties"
        );
    }

    function addNewClass(ShakerClass memory _sc) external onlyOwner {
        tokenAvailabilty.push(_sc);
    }

    function updateClassValues(uint8 index, ShakerClass calldata values)
        external
        onlyOwner
    {
        ShakerClass storage oldValues = tokenAvailabilty[index];
        oldValues.amount = values.amount;
        oldValues.price = values.price;
    }

    function _mint(address _to, uint256 _tokenId)
        internal
        virtual
        override
        canHaveShaker(_to)
    {
        super._mint(_to, _tokenId);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual override canHaveShaker(_to) {
        super._transfer(_from, _to, _tokenId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    function getShakerHash(
        uint16 _level,
        uint8 _civilization,
        uint8 _class
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_level, _civilization, _class));
    }

    function primitiveShaker(uint8 _classType)
        public
        pure
        returns (Shaker memory)
    {
        return Shaker({level: 0, civilization: 0, class: _classType});
    }

    function payOut(address payable _to, uint _transactionGas)
        public
        onlyOwner
    {
        (bool _sent, ) = _to.call{
            value: address(this).balance,
            gas: _transactionGas
        }("");
        require(_sent, "Pay out did not occurred");
    }

    modifier canHaveShaker(address _addr) {
        require(
            balanceOf(_addr) < MAX_SHAKERS,
            "Address has already maximum number of shakers"
        );
        _;
    }

    modifier hasShaker(uint _tokenId) {
        require(_exists(_tokenId), "Non-existant shaker id");
        _;
    }

    modifier validURI(string memory _link) {
        require(!_link.empty(), "Invalid URI");
        _;
    }
}
