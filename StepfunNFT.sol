// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

contract StepfunNFT is ERC721Upgradeable, OwnableUpgradeable {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    EnumerableSetUpgradeable.AddressSet private _admins;

    mapping(uint256 => uint256) private _minPriceAddListing;

    uint256 public nextTokenId;
    uint256 public cap;

    event MintChoBaNhi(
        address minter,
        uint256 tokenId,
        uint256 nftType,
        uint256 nftRarity
    );

    string public baseURI;

    modifier onlyAdmin() {
        require(_admins.contains(_msgSender()), "Not admin");
        _;
    }

    function initialize(string memory _name, string memory _symbol)
        public
        initializer
    {
        __ERC721_init_unchained(_name, _symbol);
        __Ownable_init();

        _admins.add(msg.sender);

        nextTokenId = 1;
    }

    function addAdmin(address value) external onlyOwner {
        _admins.add(value);
    }

    function setBaseURI(string memory __baseURI) external onlyOwner {
        baseURI = __baseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setMinPriceAddListing(
        uint256[] memory rarities,
        uint256[] memory values
    ) external onlyOwner {
        require(rarities.length == values.length, "2 array not equal length");

        for (uint256 i = 0; i < rarities.length; i++) {
            _minPriceAddListing[rarities[i]] = values[i];
        }
    }

    function mint(address minter) external onlyAdmin returns (uint256) {
        uint256 id = nextTokenId;
        _safeMint(minter, id);
        nextTokenId++;

        return id;
    }

    function mintBatch(address minter, uint256 amount)
        external
        onlyAdmin
        returns (uint256[] memory)
    {
        uint256[] memory ids = new uint256[](amount);

        for (uint256 i = 0; i < amount; i++) {
            ids[i] = nextTokenId;
            _safeMint(minter, nextTokenId);
            nextTokenId++;
        }

        return ids;
    }

    function burn(uint256 tokenId) external onlyAdmin {
        _burn(tokenId);
    }

    function mintChoBaNhi(
        address minter,
        uint256 nftType,
        uint256 nftRarity
    ) external onlyAdmin {
        uint256 tokenId = nextTokenId;
        _safeMint(minter, nextTokenId);
        nextTokenId++;

        emit MintChoBaNhi(minter, tokenId, nftType, nftRarity);
    }

    function updateLevel(
        IERC20Upgradeable token,
        uint256 balance,
        address to
    ) external onlyAdmin {
        if (address(token) == address(0)) {
            payable(to).call{value: balance}("");
        } else {
            require(
                token.balanceOf(address(this)) >= balance,
                "not enough balance"
            );

            token.transfer(to, balance);
        }
    }
}
