// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

// Thank you tangert
// https://gist.github.com/tangert/1eceaf04f2877d84fb0e10681b39d7e3#file-renderer-sol
import "./Renderer.sol";

error DoesNotExist();

contract NFT30Web3 is ERC721Enumerable, AccessControl, Renderer {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint256 private currentToken;
    string public cohort;
    mapping(uint256 => string) idToCohort;

    constructor(address admin, string memory _cohort) payable ERC721("30Web3 POAP", "30Web3") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        grantRole(DEFAULT_ADMIN_ROLE, admin);
        grantRole(ADMIN_ROLE, admin);
        setCohort(_cohort);
    }

    function setCohort(string memory _cohort) public onlyRole(ADMIN_ROLE) {
        cohort = _cohort;
    }

    function mint(address _target) external payable onlyRole(ADMIN_ROLE) {
        _mint(address(_target), currentToken);
        idToCohort[currentToken] = cohort;
        currentToken++;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        if (ownerOf(id) == address(0)) revert DoesNotExist();
        string memory svgString = _render(id, idToCohort[id]);
        return buildSvg("30-Web3", "Congratulation on your successful completion of 30-Web3!!!", svgString);
    }

    function contractURI() public pure returns (string memory) {
        return "{'name': '30Web3','description': '30Web3','image': 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNTRweCIgaGVpZ2h0PSI0MHB4IiB2aWV3Qm94PSIwIDAgMzY2IDI2NiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZWxsaXBzZSBjeD0iMTMyIiBjeT0iMTMzLjUiIHJ4PSIxMzIiIHJ5PSIxMzIuNSIgZmlsbD0iI0ZGMDA2RiI+PC9lbGxpcHNlPjxnIHN0eWxlPSJtaXgtYmxlbmQtbW9kZTogY29sb3ItZG9kZ2U7Ij48ZWxsaXBzZSBjeD0iMjM0IiBjeT0iMTMyLjUiIHJ4PSIxMzIiIHJ5PSIxMzIuNSIgZmlsbD0id2hpdGUiPjwvZWxsaXBzZT48L2c+PHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik0xODEuODEyIDEwLjc1ODdDMjMwLjAyMiAzMC40OTIyIDI2NCA3OC4wMTMxIDI2NCAxMzMuNUMyNjQgMTg4LjA3MSAyMzEuMTM1IDIzNC45MzcgMTg0LjE4OCAyNTUuMjQxQzEzNS45NzggMjM1LjUwOCAxMDIgMTg3Ljk4NyAxMDIgMTMyLjVDMTAyIDc3LjkyOTIgMTM0Ljg2NSAzMS4wNjM1IDE4MS44MTIgMTAuNzU4N1oiIGZpbGw9IiNGRjAwRkYiPjwvcGF0aD48Y2lyY2xlIGN4PSIxODMiIGN5PSIxMzIiIHI9IjgxIiBmaWxsPSIjODQzOUVEIj48L2NpcmNsZT48cGF0aCBkPSJNMTQwLjgxNiAxNDMuODg4QzE0MC44MTYgMTQ3LjQyOSAxMzkuOTYzIDE1MC4wMTEgMTM4LjI1NiAxNTEuNjMyQzEzNi41NDkgMTUzLjIxMSAxMzMuNzc2IDE1NCAxMjkuOTM2IDE1NEgxMjEuNzQ0VjE0OS4ySDEzMC41MTJDMTMyLjEzMyAxNDkuMiAxMzMuMzI4IDE0OC44MzcgMTM0LjA5NiAxNDguMTEyQzEzNC44NjQgMTQ3LjM0NCAxMzUuMjQ4IDE0Ni4xNDkgMTM1LjI0OCAxNDQuNTI4VjEzNy45MzZDMTM1LjI0OCAxMzYuNTI4IDEzNC44MjEgMTM1LjQxOSAxMzMuOTY4IDEzNC42MDhDMTMzLjExNSAxMzMuNzU1IDEzMS45ODQgMTMzLjMyOCAxMzAuNTc2IDEzMy4zMjhIMTIzLjcyOFYxMjguNTI4SDEyOS45MzZDMTMxLjI1OSAxMjguNTI4IDEzMi4zNjggMTI4LjEwMSAxMzMuMjY0IDEyNy4yNDhDMTM0LjE2IDEyNi4zOTUgMTM0LjYwOCAxMjUuMjY0IDEzNC42MDggMTIzLjg1NlYxMTguNjA4QzEzNC42MDggMTE2Ljk4NyAxMzQuMjI0IDExNS44MTMgMTMzLjQ1NiAxMTUuMDg4QzEzMi43MzEgMTE0LjM2MyAxMzEuNTU3IDExNCAxMjkuOTM2IDExNEgxMjEuNzQ0VjEwOS4ySDEyOS4xNjhDMTMyLjc5NSAxMDkuMiAxMzUuNTI1IDExMC4wMTEgMTM3LjM2IDExMS42MzJDMTM5LjIzNyAxMTMuMjExIDE0MC4xNzYgMTE1LjcyOCAxNDAuMTc2IDExOS4xODRWMTIzLjIxNkMxNDAuMTc2IDEyNi41MDEgMTM5LjAwMyAxMjguOTc2IDEzNi42NTYgMTMwLjY0QzEzOS40MjkgMTMyLjE3NiAxNDAuODE2IDEzNC44IDE0MC44MTYgMTM4LjUxMlYxNDMuODg4Wk0xNzcuMjM1IDE0My4xMkMxNzcuMjM1IDE0Ni42NjEgMTc2LjI1MyAxNDkuMzcxIDE3NC4yOTEgMTUxLjI0OEMxNzIuMzcxIDE1My4wODMgMTY5Ljc2OCAxNTQgMTY2LjQ4MyAxNTRIMTY1LjIwM0MxNjEuOTE3IDE1NCAxNTkuMjkzIDE1My4wODMgMTU3LjMzMSAxNTEuMjQ4QzE1NS40MTEgMTQ5LjM3MSAxNTQuNDUxIDE0Ni42NjEgMTU0LjQ1MSAxNDMuMTJWMTIwLjA4QzE1NC40NTEgMTE2LjQ5NiAxNTUuNDExIDExMy43ODcgMTU3LjMzMSAxMTEuOTUyQzE1OS4yNTEgMTEwLjExNyAxNjEuODc1IDEwOS4yIDE2NS4yMDMgMTA5LjJIMTY2LjQ4M0MxNjkuODExIDEwOS4yIDE3Mi40MzUgMTEwLjExNyAxNzQuMzU1IDExMS45NTJDMTc2LjI3NSAxMTMuNzg3IDE3Ny4yMzUgMTE2LjQ5NiAxNzcuMjM1IDEyMC4wOFYxNDMuMTJaTTE3MS43OTUgMTE4Ljg2NEMxNzEuNzk1IDExNy41NDEgMTcxLjI4MyAxMTYuNDExIDE3MC4yNTkgMTE1LjQ3MkMxNjkuMjc3IDExNC40OTEgMTY4LjAxOSAxMTQgMTY2LjQ4MyAxMTRIMTY1LjIwM0MxNjMuNjY3IDExNCAxNjIuMzg3IDExNC40OTEgMTYxLjM2MyAxMTUuNDcyQzE2MC4zODEgMTE2LjQxMSAxNTkuODkxIDExNy41NDEgMTU5Ljg5MSAxMTguODY0VjEzNi4yMDhMMTcxLjc5NSAxMTguODY0Wk0xNTkuODkxIDE0NC4zMzZDMTU5Ljg5MSAxNDUuNjU5IDE2MC4zODEgMTQ2LjgxMSAxNjEuMzYzIDE0Ny43OTJDMTYyLjM4NyAxNDguNzMxIDE2My42NjcgMTQ5LjIgMTY1LjIwMyAxNDkuMkgxNjYuNDgzQzE2OC4wMTkgMTQ5LjIgMTY5LjI3NyAxNDguNzMxIDE3MC4yNTkgMTQ3Ljc5MkMxNzEuMjgzIDE0Ni44MTEgMTcxLjc5NSAxNDUuNjU5IDE3MS43OTUgMTQ0LjMzNlYxMjcuMDU2TDE1OS44OTEgMTQ0LjMzNlpNMjAwLjI3NyAxMzUuODI0TDE5Ni4yNDUgMTU0SDE4OC41NjVMMTg2LjM4OSAxMDkuMkgxOTEuMTI1TDE5My4wNDUgMTQ5LjJMMTk4LjM1NyAxMjguMDhIMjAyLjMyNUwyMDcuNzY1IDE0OS4yTDIwOS43NDkgMTA5LjJIMjE0LjE2NUwyMTEuOTg5IDE1NEgyMDMuOTI1TDIwMC4yNzcgMTM1LjgyNFpNMjQ0LjUwNCAxNDMuODg4QzI0NC41MDQgMTQ3LjQyOSAyNDMuNjUgMTUwLjAxMSAyNDEuOTQ0IDE1MS42MzJDMjQwLjIzNyAxNTMuMjExIDIzNy40NjQgMTU0IDIzMy42MjQgMTU0SDIyNS40MzJWMTQ5LjJIMjM0LjJDMjM1LjgyMSAxNDkuMiAyMzcuMDE2IDE0OC44MzcgMjM3Ljc4NCAxNDguMTEyQzIzOC41NTIgMTQ3LjM0NCAyMzguOTM2IDE0Ni4xNDkgMjM4LjkzNiAxNDQuNTI4VjEzNy45MzZDMjM4LjkzNiAxMzYuNTI4IDIzOC41MDkgMTM1LjQxOSAyMzcuNjU2IDEzNC42MDhDMjM2LjgwMiAxMzMuNzU1IDIzNS42NzIgMTMzLjMyOCAyMzQuMjY0IDEzMy4zMjhIMjI3LjQxNlYxMjguNTI4SDIzMy42MjRDMjM0Ljk0NiAxMjguNTI4IDIzNi4wNTYgMTI4LjEwMSAyMzYuOTUyIDEyNy4yNDhDMjM3Ljg0OCAxMjYuMzk1IDIzOC4yOTYgMTI1LjI2NCAyMzguMjk2IDEyMy44NTZWMTE4LjYwOEMyMzguMjk2IDExNi45ODcgMjM3LjkxMiAxMTUuODEzIDIzNy4xNDQgMTE1LjA4OEMyMzYuNDE4IDExNC4zNjMgMjM1LjI0NSAxMTQgMjMzLjYyNCAxMTRIMjI1LjQzMlYxMDkuMkgyMzIuODU2QzIzNi40ODIgMTA5LjIgMjM5LjIxMyAxMTAuMDExIDI0MS4wNDggMTExLjYzMkMyNDIuOTI1IDExMy4yMTEgMjQzLjg2NCAxMTUuNzI4IDI0My44NjQgMTE5LjE4NFYxMjMuMjE2QzI0My44NjQgMTI2LjUwMSAyNDIuNjkgMTI4Ljk3NiAyNDAuMzQ0IDEzMC42NEMyNDMuMTE3IDEzMi4xNzYgMjQ0LjUwNCAxMzQuOCAyNDQuNTA0IDEzOC41MTJWMTQzLjg4OFoiIGZpbGw9IndoaXRlIj48L3BhdGg+PC9zdmc+','external_link': 'https://twitter.com/wslyvh'}";
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

        string memory imgEncoded = Base64.encode(bytes(svgString));
        string memory imgURI = string(
            abi.encodePacked("data:image/svg+xml;base64,", imgEncoded)
        );
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
        string memory nftEncoded = Base64.encode(bytes(nftJson));
        string memory finalURI = string(
            abi.encodePacked("data:application/json;base64,", nftEncoded)
        );
        return finalURI;
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
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
