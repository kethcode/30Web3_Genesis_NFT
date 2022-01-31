// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


// Thank you tangert
// https://gist.github.com/tangert/1eceaf04f2877d84fb0e10681b39d7e3#file-renderer-sol
import "./Renderer.sol";

error DoesNotExist();
error AlreadyClaimed();
error InvalidRoot();
error NotOnWhitelist();

contract NFT30Web3 is ERC721Enumerable, AccessControl, Renderer {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint256 private currentToken;
    mapping(uint256 => address) public minterOf;
    mapping(address => bool) public claimed;
    string public cohort;
    mapping(uint256 => string) idToCohort;

    bytes32 private whitelistRoot;

    constructor(address admin, string memory _cohort, bytes32 _whitelistRoot) payable ERC721("30Web3 POAP", "30Web3") {
        
        _setupRole(ADMIN_ROLE, admin);
        setCohort(_cohort);
        whitelistRoot = _whitelistRoot;
        // cohort = "Genesis";
    }

    function setWhitelistRoot(bytes32 _whitelistRoot) external onlyRole(ADMIN_ROLE) {
        whitelistRoot = _whitelistRoot;
    }

    function getWhitelistRoot() external view onlyRole(ADMIN_ROLE) returns (bytes32) {
        return whitelistRoot;
    }

    function verify(bytes32[] memory _proof, bytes32 _root, bytes32 _leaf) external view returns (bool) {
        if(whitelistRoot != _root) return false;
        return MerkleProof.verify(_proof, _root, _leaf);
    }

    function mint(bytes32[] memory _proof, bytes32 _root, bytes32 _leaf) external payable {
        //require(claimed[msg.sender] == false, "Already Claimed");
        if(claimed[msg.sender] == true) revert AlreadyClaimed(); // this is a little cheaper on gas
        if(whitelistRoot != _root) revert InvalidRoot();
        if(MerkleProof.verify(_proof, _root, _leaf) == false) revert NotOnWhitelist();

        _mint(msg.sender, currentToken);
        claimed[msg.sender] = true;

        minterOf[currentToken] = ownerOf(currentToken);
        idToCohort[currentToken] = cohort;
        currentToken++;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        if (ownerOf(id) == address(0)) revert DoesNotExist();
        string memory svgString = _render(id, idToCohort[id]);
        return buildSvg("30-Web3", "Congratulation on your successful completion of 30-Web3!!!", svgString);
    }

    function ownsNFT() public view returns (bool) {
        return claimed[msg.sender];
    }

    //https://ethereum.stackexchange.com/questions/8346/convert-address-to-string
    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function buildSvg(
        string memory nftName,
        string memory nftDescription,
        string memory svgString
    ) public pure returns (string memory) {
        // console.log("\n--------------------");
        // console.log(svgString);
        // console.log("--------------------\n");

        string memory imgEncoded = Base64.encode(bytes(svgString));
        // console.log("\n--------------------");
        // console.log(imgEncoded);
        // console.log("--------------------\n");

        string memory imgURI = string(
            abi.encodePacked("data:image/svg+xml;base64,", imgEncoded)
        );
        // console.log("\n--------------------");
        // console.log(imgURI);
        // console.log("--------------------\n");

        string memory nftJson = string(
            abi.encodePacked(
                '{"name": "',
                nftName,
                '", "description": "',
                nftDescription,
                '", "image": "',
                imgURI,
                '"}'
            )
        );
        // console.log("\n--------------------");
        // console.log(nftJson);
        // console.log("--------------------\n");

        string memory nftEncoded = Base64.encode(bytes(nftJson));
        // console.log("\n--------------------");
        // console.log(nftEncoded);
        // console.log("--------------------\n");

        string memory finalURI = string(
            abi.encodePacked("data:application/json;base64,", nftEncoded)
        );
        // console.log("\n--------------------");
        // console.log(finalURI);
        // console.log("--------------------\n");

        return finalURI;
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function withdraw() external onlyRole(ADMIN_ROLE) {
        uint balanceWithdraw = address(this).balance;
        payable(msg.sender).transfer(balanceWithdraw);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setCohort(string memory _cohort) public onlyRole(ADMIN_ROLE) {
        cohort = _cohort;
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
                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(18, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(12, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(6, input), 0x3F)))
                )
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
