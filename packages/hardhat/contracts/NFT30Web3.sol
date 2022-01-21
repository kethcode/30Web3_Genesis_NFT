// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.6.0 <0.9.0;

// Thank you m1guelpf
// https://github.com/m1guelpf/erc721-drop
import "./LilOwnable.sol";

// Thank you transmissions11
// https://github.com/Rari-Capital/solmate
import "@rari-capital/solmate/src/tokens/ERC721.sol";
import "@rari-capital/solmate/src/utils/SafeTransferLib.sol";

// Thank you OpenZeppelin
//import "@openzeppelin/contracts/utils/Strings.sol"; // kinda dont want to use Strings.  will replace later.

error DoesNotExist();

contract NFT30Web3 is LilOwnable, ERC721 {

    uint256 public totalSupply;
    mapping(uint256 => address) public minterOf;

    constructor() payable ERC721("30Web3 Genesis", "30Web3_1") {}

    function mint() external payable {        
        _mint(msg.sender, totalSupply);
        minterOf[totalSupply] = ownerOf[totalSupply];
        totalSupply++;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        if (ownerOf[id] == address(0)) revert DoesNotExist();

        string memory svgString = string(
            abi.encodePacked(
                "<svg width='320' height='240' viewBox='0 0 320 240' fill='none' xmlns='http://www.w3.org/2000/svg'><rect x='10' y='10' width='300' height='220' rx='12' ry='12' fill='lightsteelblue'/><circle cx='70' cy='50' r='30' fill='white' fill-opacity='0.8'/><circle cx='50' cy='50' r='30' fill='deeppink' fill-opacity='0.8'/><circle cx='60' cy='50' r='20' fill='darkviolet' fill-opacity='0.8'/><text x='45' y='54' fill='white' font-size='12px' font-family='monospace'>30W3</text><text x='160' y='60' fill='yellow' font-size='24px' font-family='monospace'>Genesis</text><text x='160' y='150' fill='darkorchid' font-size='28px' font-family='monospace' text-anchor='middle' opacity='0.9'>Web3 Buidloooor</text><text x='50%' y='90%' fill='black' font-size='10px' font-family='monospace' text-anchor='middle'><animate attributeName='x' values='45%;55%;45%' dur='4s' repeatCount='indefinite' />",
                "0x",
                toAsciiString(minterOf[id]),
                "</text></svg>"
            )
        );

        return buildSvg("30Web3 Genesis","30Web3_1",svgString);
    }

    //https://ethereum.stackexchange.com/questions/8346/convert-address-to-string
    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    function buildSvg(string memory nftName, string memory nftDescription, string memory svgString) public pure returns (string memory)
    {
        // console.log("\n--------------------");
        // console.log(svgString);
        // console.log("--------------------\n");

        string memory imgEncoded = Base64.encode(bytes(svgString));
        // console.log("\n--------------------");
        // console.log(imgEncoded);
        // console.log("--------------------\n");

        string memory imgURI = string(abi.encodePacked('data:image/svg+xml;base64,', imgEncoded));
        // console.log("\n--------------------");
        // console.log(imgURI);
        // console.log("--------------------\n");

        string memory nftJson = string(abi.encodePacked('{"name": "', nftName, '", "description": "', nftDescription, '", "image": "', imgURI, '"}'));
        // console.log("\n--------------------");
        // console.log(nftJson);
        // console.log("--------------------\n");

        string memory nftEncoded = Base64.encode(bytes(nftJson));
        // console.log("\n--------------------");
        // console.log(nftEncoded);
        // console.log("--------------------\n");

        string memory finalURI = string(abi.encodePacked("data:application/json;base64,", nftEncoded));
        // console.log("\n--------------------");
        // console.log(finalURI);
        // console.log("--------------------\n");

        return finalURI;
    }


    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function withdraw() external {
        if (msg.sender != _owner) revert NotOwner();

        SafeTransferLib.safeTransferETH(msg.sender, address(this).balance);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        pure
        override(LilOwnable, ERC721)
        returns (bool)
    {
        return
            interfaceId == 0x7f5828d0 || // ERC165 Interface ID for ERC173
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f || // ERC165 Interface ID for ERC165
            interfaceId == 0x01ffc9a7; // ERC165 Interface ID for ERC721Metadata
    }
}

// Primes NFT
//https://etherscan.io/address/0xBDA937F5C5f4eFB2261b6FcD25A71A1C350FdF20#code#L1507
library Base64 {
    string internal constant TABLE_ENCODE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";

        // load the table into memory
        string memory table = TABLE_ENCODE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {

            } lt(dataPtr, endPtr) {

            } {
                // read 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // write 4 characters
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }
}