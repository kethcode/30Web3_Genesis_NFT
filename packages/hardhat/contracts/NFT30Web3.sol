// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

/*
30Web3

ERC721, Enumerable, Ownable, Adminlist

Core is ERC721 library from Solmate by @transmissions11, modified to support
Open Zeppelin Enumerable extension and hooks. Lilownable by @m1guelpf. Adminlist
based on a branch of Open Zeppelin ownership branch from 2018.

ERC721 Solmate: https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC721.sol
OZ Enumerable:  https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.4.2/contracts/token/ERC721/extensions/ERC721Enumerable.sol
Lilownable:     https://github.com/m1guelpf/erc721-drop/blob/main/src/LilOwnable.sol
Adminlist:      https://github.com/OpenZeppelin/openzeppelin-contracts/blob/025c9bdcde412e65a307e4985151e7c023fd3870/contracts/ownership/Whitelist.sol

@author kethic, xavier, larkef
*/

/// ----------------------------------------------------------------------------
/// Imports
/// ----------------------------------------------------------------------------
import "./ERC721_Solmate_Hooked.sol";
import "./LilOwnable.sol";
import "./Adminlist.sol";

// Thank you tangert
// https://gist.github.com/tangert/1eceaf04f2877d84fb0e10681b39d7e3#file-renderer-sol
import "./Renderer.sol";

/// ----------------------------------------------------------------------------
/// Enums and Structs
/// ----------------------------------------------------------------------------

/// ----------------------------------------------------------------------------
/// Errors
/// ----------------------------------------------------------------------------
error InvalidToken();
error IndexOutOfBounds();
error TransferFailed();
error NoReentrancy();

contract NFT30Web3 is ERC721, LilOwnable, Adminlist, Renderer {

    /// ------------------------------------------------------------------------
    /// Events
    /// ------------------------------------------------------------------------

    /// ------------------------------------------------------------------------
    /// Variables
    /// ------------------------------------------------------------------------

    uint256 private currentToken;
    string public cohort;
    mapping(uint256 => string) idToCohort;

    uint8 private _mutex = 1;

    /// ------------------------------------------------------------------------
    /// Modifiers
    /// ------------------------------------------------------------------------

    modifier isValidToken(uint256 id) {
        if(ownerOf[id] == address(0)) revert InvalidToken();
        _;
    }

    modifier mutex() {
        if(_mutex == 2) revert NoReentrancy();

        _mutex = 2;
        _;
        _mutex = 1;
    }
    
    /// ------------------------------------------------------------------------
    /// Functions
    /// ------------------------------------------------------------------------

    constructor(
        address[] memory _adminlist,
        string memory _cohort
    ) ERC721 (
        "30Web3 POAP",
        "30Web3"
    ) {

        // Deployer has Admin Rights
        _setupAdmin(msg.sender);

        // Add the other Admins
        uint16 length = uint16(_adminlist.length);
        for(uint16 i=0; i < length; i = uncheckedInc(i))
        {
            _setupAdmin(_adminlist[i]);
        }

        setCohort(_cohort);
    }

    function setCohort(
        string memory _cohort
    )
        public 
        onlyAdmin
    {
        cohort = _cohort;
    }

    function mint(
        address _target
    )
        external
        payable 
        onlyAdmin
        mutex
    {
        _mint(address(_target), currentToken);
        idToCohort[currentToken] = cohort;
        currentToken++;
    }

    function tokenURI(
        uint256 id
    )
        public
        view
        override
        isValidToken(id)
        returns (string memory) 
    {
        string memory svgString = _render(id, idToCohort[id]);
        return buildSvg("30-Web3", "Congratulation on your successful completion of 30-Web3!!!", svgString);
    }

    function contractURI()
        public
        pure 
        returns (string memory) 
    {
        return "{'name': '30Web3', 'description': '30Web3', 'image': 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNTRweCIgaGVpZ2h0PSI0MHB4IiB2aWV3Qm94PSIwIDAgMzY2IDI2NiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZWxsaXBzZSBjeD0iMTMyIiBjeT0iMTMzLjUiIHJ4PSIxMzIiIHJ5PSIxMzIuNSIgZmlsbD0iI0ZGMDA2RiI+PC9lbGxpcHNlPjxnIHN0eWxlPSJtaXgtYmxlbmQtbW9kZTogY29sb3ItZG9kZ2U7Ij48ZWxsaXBzZSBjeD0iMjM0IiBjeT0iMTMyLjUiIHJ4PSIxMzIiIHJ5PSIxMzIuNSIgZmlsbD0id2hpdGUiPjwvZWxsaXBzZT48L2c+PHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik0xODEuODEyIDEwLjc1ODdDMjMwLjAyMiAzMC40OTIyIDI2NCA3OC4wMTMxIDI2NCAxMzMuNUMyNjQgMTg4LjA3MSAyMzEuMTM1IDIzNC45MzcgMTg0LjE4OCAyNTUuMjQxQzEzNS45NzggMjM1LjUwOCAxMDIgMTg3Ljk4NyAxMDIgMTMyLjVDMTAyIDc3LjkyOTIgMTM0Ljg2NSAzMS4wNjM1IDE4MS44MTIgMTAuNzU4N1oiIGZpbGw9IiNGRjAwRkYiPjwvcGF0aD48Y2lyY2xlIGN4PSIxODMiIGN5PSIxMzIiIHI9IjgxIiBmaWxsPSIjODQzOUVEIj48L2NpcmNsZT48cGF0aCBkPSJNMTQwLjgxNiAxNDMuODg4QzE0MC44MTYgMTQ3LjQyOSAxMzkuOTYzIDE1MC4wMTEgMTM4LjI1NiAxNTEuNjMyQzEzNi41NDkgMTUzLjIxMSAxMzMuNzc2IDE1NCAxMjkuOTM2IDE1NEgxMjEuNzQ0VjE0OS4ySDEzMC41MTJDMTMyLjEzMyAxNDkuMiAxMzMuMzI4IDE0OC44MzcgMTM0LjA5NiAxNDguMTEyQzEzNC44NjQgMTQ3LjM0NCAxMzUuMjQ4IDE0Ni4xNDkgMTM1LjI0OCAxNDQuNTI4VjEzNy45MzZDMTM1LjI0OCAxMzYuNTI4IDEzNC44MjEgMTM1LjQxOSAxMzMuOTY4IDEzNC42MDhDMTMzLjExNSAxMzMuNzU1IDEzMS45ODQgMTMzLjMyOCAxMzAuNTc2IDEzMy4zMjhIMTIzLjcyOFYxMjguNTI4SDEyOS45MzZDMTMxLjI1OSAxMjguNTI4IDEzMi4zNjggMTI4LjEwMSAxMzMuMjY0IDEyNy4yNDhDMTM0LjE2IDEyNi4zOTUgMTM0LjYwOCAxMjUuMjY0IDEzNC42MDggMTIzLjg1NlYxMTguNjA4QzEzNC42MDggMTE2Ljk4NyAxMzQuMjI0IDExNS44MTMgMTMzLjQ1NiAxMTUuMDg4QzEzMi43MzEgMTE0LjM2MyAxMzEuNTU3IDExNCAxMjkuOTM2IDExNEgxMjEuNzQ0VjEwOS4ySDEyOS4xNjhDMTMyLjc5NSAxMDkuMiAxMzUuNTI1IDExMC4wMTEgMTM3LjM2IDExMS42MzJDMTM5LjIzNyAxMTMuMjExIDE0MC4xNzYgMTE1LjcyOCAxNDAuMTc2IDExOS4xODRWMTIzLjIxNkMxNDAuMTc2IDEyNi41MDEgMTM5LjAwMyAxMjguOTc2IDEzNi42NTYgMTMwLjY0QzEzOS40MjkgMTMyLjE3NiAxNDAuODE2IDEzNC44IDE0MC44MTYgMTM4LjUxMlYxNDMuODg4Wk0xNzcuMjM1IDE0My4xMkMxNzcuMjM1IDE0Ni42NjEgMTc2LjI1MyAxNDkuMzcxIDE3NC4yOTEgMTUxLjI0OEMxNzIuMzcxIDE1My4wODMgMTY5Ljc2OCAxNTQgMTY2LjQ4MyAxNTRIMTY1LjIwM0MxNjEuOTE3IDE1NCAxNTkuMjkzIDE1My4wODMgMTU3LjMzMSAxNTEuMjQ4QzE1NS40MTEgMTQ5LjM3MSAxNTQuNDUxIDE0Ni42NjEgMTU0LjQ1MSAxNDMuMTJWMTIwLjA4QzE1NC40NTEgMTE2LjQ5NiAxNTUuNDExIDExMy43ODcgMTU3LjMzMSAxMTEuOTUyQzE1OS4yNTEgMTEwLjExNyAxNjEuODc1IDEwOS4yIDE2NS4yMDMgMTA5LjJIMTY2LjQ4M0MxNjkuODExIDEwOS4yIDE3Mi40MzUgMTEwLjExNyAxNzQuMzU1IDExMS45NTJDMTc2LjI3NSAxMTMuNzg3IDE3Ny4yMzUgMTE2LjQ5NiAxNzcuMjM1IDEyMC4wOFYxNDMuMTJaTTE3MS43OTUgMTE4Ljg2NEMxNzEuNzk1IDExNy41NDEgMTcxLjI4MyAxMTYuNDExIDE3MC4yNTkgMTE1LjQ3MkMxNjkuMjc3IDExNC40OTEgMTY4LjAxOSAxMTQgMTY2LjQ4MyAxMTRIMTY1LjIwM0MxNjMuNjY3IDExNCAxNjIuMzg3IDExNC40OTEgMTYxLjM2MyAxMTUuNDcyQzE2MC4zODEgMTE2LjQxMSAxNTkuODkxIDExNy41NDEgMTU5Ljg5MSAxMTguODY0VjEzNi4yMDhMMTcxLjc5NSAxMTguODY0Wk0xNTkuODkxIDE0NC4zMzZDMTU5Ljg5MSAxNDUuNjU5IDE2MC4zODEgMTQ2LjgxMSAxNjEuMzYzIDE0Ny43OTJDMTYyLjM4NyAxNDguNzMxIDE2My42NjcgMTQ5LjIgMTY1LjIwMyAxNDkuMkgxNjYuNDgzQzE2OC4wMTkgMTQ5LjIgMTY5LjI3NyAxNDguNzMxIDE3MC4yNTkgMTQ3Ljc5MkMxNzEuMjgzIDE0Ni44MTEgMTcxLjc5NSAxNDUuNjU5IDE3MS43OTUgMTQ0LjMzNlYxMjcuMDU2TDE1OS44OTEgMTQ0LjMzNlpNMjAwLjI3NyAxMzUuODI0TDE5Ni4yNDUgMTU0SDE4OC41NjVMMTg2LjM4OSAxMDkuMkgxOTEuMTI1TDE5My4wNDUgMTQ5LjJMMTk4LjM1NyAxMjguMDhIMjAyLjMyNUwyMDcuNzY1IDE0OS4yTDIwOS43NDkgMTA5LjJIMjE0LjE2NUwyMTEuOTg5IDE1NEgyMDMuOTI1TDIwMC4yNzcgMTM1LjgyNFpNMjQ0LjUwNCAxNDMuODg4QzI0NC41MDQgMTQ3LjQyOSAyNDMuNjUgMTUwLjAxMSAyNDEuOTQ0IDE1MS42MzJDMjQwLjIzNyAxNTMuMjExIDIzNy40NjQgMTU0IDIzMy42MjQgMTU0SDIyNS40MzJWMTQ5LjJIMjM0LjJDMjM1LjgyMSAxNDkuMiAyMzcuMDE2IDE0OC44MzcgMjM3Ljc4NCAxNDguMTEyQzIzOC41NTIgMTQ3LjM0NCAyMzguOTM2IDE0Ni4xNDkgMjM4LjkzNiAxNDQuNTI4VjEzNy45MzZDMjM4LjkzNiAxMzYuNTI4IDIzOC41MDkgMTM1LjQxOSAyMzcuNjU2IDEzNC42MDhDMjM2LjgwMiAxMzMuNzU1IDIzNS42NzIgMTMzLjMyOCAyMzQuMjY0IDEzMy4zMjhIMjI3LjQxNlYxMjguNTI4SDIzMy42MjRDMjM0Ljk0NiAxMjguNTI4IDIzNi4wNTYgMTI4LjEwMSAyMzYuOTUyIDEyNy4yNDhDMjM3Ljg0OCAxMjYuMzk1IDIzOC4yOTYgMTI1LjI2NCAyMzguMjk2IDEyMy44NTZWMTE4LjYwOEMyMzguMjk2IDExNi45ODcgMjM3LjkxMiAxMTUuODEzIDIzNy4xNDQgMTE1LjA4OEMyMzYuNDE4IDExNC4zNjMgMjM1LjI0NSAxMTQgMjMzLjYyNCAxMTRIMjI1LjQzMlYxMDkuMkgyMzIuODU2QzIzNi40ODIgMTA5LjIgMjM5LjIxMyAxMTAuMDExIDI0MS4wNDggMTExLjYzMkMyNDIuOTI1IDExMy4yMTEgMjQzLjg2NCAxMTUuNzI4IDI0My44NjQgMTE5LjE4NFYxMjMuMjE2QzI0My44NjQgMTI2LjUwMSAyNDIuNjkgMTI4Ljk3NiAyNDAuMzQ0IDEzMC42NEMyNDMuMTE3IDEzMi4xNzYgMjQ0LjUwNCAxMzQuOCAyNDQuNTA0IDEzOC41MTJWMTQzLjg4OFoiIGZpbGw9IndoaXRlIj48L3BhdGg+PC9zdmc+', 'external_link': 'https://twitter.com/wslyvh'}";
    }

    function withdraw()
        external
        onlyAdmin
    {
        safeTransferETH(msg.sender, address(this).balance);
    }

    /// ------------------------------------------------------------------------
    /// ERC721Enumerable Variables
    /// ------------------------------------------------------------------------

    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /// ------------------------------------------------------------------------
    /// ERC721Enumerable Functions
    /// ------------------------------------------------------------------------

    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    )
        public
        view
        returns (uint256) 
    {
        if(index >= ERC721.balanceOf[owner]) revert IndexOutOfBounds();
        return _ownedTokens[owner][index];
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _allTokens.length;
    }

    function tokenByIndex(
        uint256 index
    )
        public
        view
        returns (uint256) 
    {
        if(index >= totalSupply()) revert IndexOutOfBounds();
        return _allTokens[index];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);   
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(
        address to,
        uint256 tokenId
    )
        private
    {
        uint256 length = ERC721.balanceOf[to];
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(
        uint256 tokenId
    )
        private
    {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(
        address from, 
        uint256 tokenId
    )
        private 
    {
        uint256 lastTokenIndex = ERC721.balanceOf[from] - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];
        uint256 lastTokenId = _allTokens[lastTokenIndex];
        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }


    /// ------------------------------------------------------------------------
    /// ERC165
    /// ------------------------------------------------------------------------

    function supportsInterface(bytes4 interfaceId)
        public
        pure
        override(ERC721, LilOwnable)
        returns (bool)
    {
        return
        interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
        interfaceId == 0x7f5828d0 || // ERC165 Interface ID for ERC173
        interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
        interfaceId == 0x5b5e139f || // ERC165 Interface ID for ERC721Metadata
        interfaceId == 0x780e9d63;   // ERC165 Interface ID for ERC721Enumerable
    }

    /// ------------------------------------------------------------------------
    /// Utility Functions
    /// ------------------------------------------------------------------------

    //https://ethereum.stackexchange.com/questions/8346/convert-address-to-string
    function toAsciiString(
        address x
    )   
        internal
        pure 
        returns (string memory) 
    {
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
    ) 
        public 
        pure 
        returns (string memory) 
    {
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

    function char(
        bytes1 b
    )
        internal
        pure 
        returns (bytes1 c)
    {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    // https://gist.github.com/hrkrshnn/ee8fabd532058307229d65dcd5836ddc#the-increment-in-for-loop-post-condition-can-be-made-unchecked
    function uncheckedInc(
        uint16 i
    )
        internal
        pure 
        returns (uint16) 
    {
        unchecked {
            return i + 1;
        }
    }

    // https://github.com/Rari-Capital/solmate/blob/af8adfb66c867bc085c81018e22a98e8a9c66c20/src/utils/SafeTransferLib.sol#L16
    function safeTransferETH(
        address to,
        uint256 amount
    ) 
        internal 
    {

        bool callStatus;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            callStatus := call(gas(), to, amount, 0, 0, 0, 0)
        }

        if(!callStatus) revert TransferFailed();
    }
}

/// ----------------------------------------------------------------------------
/// External Contracts
/// ----------------------------------------------------------------------------

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
