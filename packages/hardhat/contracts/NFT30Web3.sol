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
        return buildSvg("30Web3", "Congratulation on your successful completion of 30Web3!!!", svgString);
    }

    function contractURI()
        public
        pure 
        returns (string memory) 
    {
        return "data:application/json;base64,eyJuYW1lIjoiMzBXZWIzIFBPQVAiLCJkZXNjcmlwdGlvbiI6IlJld2FyZCBmb3Igc3VjY2Vzc2Z1bCBjb21wbGV0aW9uIG9mIDMwV2ViMyEiLCJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUIzYVdSMGFEMGlOVFJ3ZUNJZ2FHVnBaMmgwUFNJME1IQjRJaUIyYVdWM1FtOTRQU0l3SURBZ016WTJJREkyTmlJZ1ptbHNiRDBpYm05dVpTSWdlRzFzYm5NOUltaDBkSEE2THk5M2QzY3Vkek11YjNKbkx6SXdNREF2YzNabklqNDhaV3hzYVhCelpTQmplRDBpTVRNeUlpQmplVDBpTVRNekxqVWlJSEo0UFNJeE16SWlJSEo1UFNJeE16SXVOU0lnWm1sc2JEMGlJMFpHTURBMlJpSStQQzlsYkd4cGNITmxQanhuSUhOMGVXeGxQU0p0YVhndFlteGxibVF0Ylc5a1pUb2dZMjlzYjNJdFpHOWtaMlU3SWo0OFpXeHNhWEJ6WlNCamVEMGlNak0wSWlCamVUMGlNVE15TGpVaUlISjRQU0l4TXpJaUlISjVQU0l4TXpJdU5TSWdabWxzYkQwaWQyaHBkR1VpUGp3dlpXeHNhWEJ6WlQ0OEwyYytQSEJoZEdnZ1ptbHNiQzF5ZFd4bFBTSmxkbVZ1YjJSa0lpQmpiR2x3TFhKMWJHVTlJbVYyWlc1dlpHUWlJR1E5SWsweE9ERXVPREV5SURFd0xqYzFPRGRETWpNd0xqQXlNaUF6TUM0ME9USXlJREkyTkNBM09DNHdNVE14SURJMk5DQXhNek11TlVNeU5qUWdNVGc0TGpBM01TQXlNekV1TVRNMUlESXpOQzQ1TXpjZ01UZzBMakU0T0NBeU5UVXVNalF4UXpFek5TNDVOemdnTWpNMUxqVXdPQ0F4TURJZ01UZzNMams0TnlBeE1ESWdNVE15TGpWRE1UQXlJRGMzTGpreU9USWdNVE0wTGpnMk5TQXpNUzR3TmpNMUlERTRNUzQ0TVRJZ01UQXVOelU0TjFvaUlHWnBiR3c5SWlOR1JqQXdSa1lpUGp3dmNHRjBhRDQ4WTJseVkyeGxJR040UFNJeE9ETWlJR041UFNJeE16SWlJSEk5SWpneElpQm1hV3hzUFNJak9EUXpPVVZFSWo0OEwyTnBjbU5zWlQ0OGNHRjBhQ0JrUFNKTk1UUXdMamd4TmlBeE5ETXVPRGc0UXpFME1DNDRNVFlnTVRRM0xqUXlPU0F4TXprdU9UWXpJREUxTUM0d01URWdNVE00TGpJMU5pQXhOVEV1TmpNeVF6RXpOaTQxTkRrZ01UVXpMakl4TVNBeE16TXVOemMySURFMU5DQXhNamt1T1RNMklERTFORWd4TWpFdU56UTBWakUwT1M0eVNERXpNQzQxTVRKRE1UTXlMakV6TXlBeE5Ea3VNaUF4TXpNdU16STRJREUwT0M0NE16Y2dNVE0wTGpBNU5pQXhORGd1TVRFeVF6RXpOQzQ0TmpRZ01UUTNMak0wTkNBeE16VXVNalE0SURFME5pNHhORGtnTVRNMUxqSTBPQ0F4TkRRdU5USTRWakV6Tnk0NU16WkRNVE0xTGpJME9DQXhNell1TlRJNElERXpOQzQ0TWpFZ01UTTFMalF4T1NBeE16TXVPVFk0SURFek5DNDJNRGhETVRNekxqRXhOU0F4TXpNdU56VTFJREV6TVM0NU9EUWdNVE16TGpNeU9DQXhNekF1TlRjMklERXpNeTR6TWpoSU1USXpMamN5T0ZZeE1qZ3VOVEk0U0RFeU9TNDVNelpETVRNeExqSTFPU0F4TWpndU5USTRJREV6TWk0ek5qZ2dNVEk0TGpFd01TQXhNek11TWpZMElERXlOeTR5TkRoRE1UTTBMakUySURFeU5pNHpPVFVnTVRNMExqWXdPQ0F4TWpVdU1qWTBJREV6TkM0Mk1EZ2dNVEl6TGpnMU5sWXhNVGd1TmpBNFF6RXpOQzQyTURnZ01URTJMams0TnlBeE16UXVNakkwSURFeE5TNDRNVE1nTVRNekxqUTFOaUF4TVRVdU1EZzRRekV6TWk0M016RWdNVEUwTGpNMk15QXhNekV1TlRVM0lERXhOQ0F4TWprdU9UTTJJREV4TkVneE1qRXVOelEwVmpFd09TNHlTREV5T1M0eE5qaERNVE15TGpjNU5TQXhNRGt1TWlBeE16VXVOVEkxSURFeE1DNHdNVEVnTVRNM0xqTTJJREV4TVM0Mk16SkRNVE01TGpJek55QXhNVE11TWpFeElERTBNQzR4TnpZZ01URTFMamN5T0NBeE5EQXVNVGMySURFeE9TNHhPRFJXTVRJekxqSXhOa014TkRBdU1UYzJJREV5Tmk0MU1ERWdNVE01TGpBd015QXhNamd1T1RjMklERXpOaTQyTlRZZ01UTXdMalkwUXpFek9TNDBNamtnTVRNeUxqRTNOaUF4TkRBdU9ERTJJREV6TkM0NElERTBNQzQ0TVRZZ01UTTRMalV4TWxZeE5ETXVPRGc0V2sweE56Y3VNak0xSURFME15NHhNa014TnpjdU1qTTFJREUwTmk0Mk5qRWdNVGMyTGpJMU15QXhORGt1TXpjeElERTNOQzR5T1RFZ01UVXhMakkwT0VNeE56SXVNemN4SURFMU15NHdPRE1nTVRZNUxqYzJPQ0F4TlRRZ01UWTJMalE0TXlBeE5UUklNVFkxTGpJd00wTXhOakV1T1RFM0lERTFOQ0F4TlRrdU1qa3pJREUxTXk0d09ETWdNVFUzTGpNek1TQXhOVEV1TWpRNFF6RTFOUzQwTVRFZ01UUTVMak0zTVNBeE5UUXVORFV4SURFME5pNDJOakVnTVRVMExqUTFNU0F4TkRNdU1USldNVEl3TGpBNFF6RTFOQzQwTlRFZ01URTJMalE1TmlBeE5UVXVOREV4SURFeE15NDNPRGNnTVRVM0xqTXpNU0F4TVRFdU9UVXlRekUxT1M0eU5URWdNVEV3TGpFeE55QXhOakV1T0RjMUlERXdPUzR5SURFMk5TNHlNRE1nTVRBNUxqSklNVFkyTGpRNE0wTXhOamt1T0RFeElERXdPUzR5SURFM01pNDBNelVnTVRFd0xqRXhOeUF4TnpRdU16VTFJREV4TVM0NU5USkRNVGMyTGpJM05TQXhNVE11TnpnM0lERTNOeTR5TXpVZ01URTJMalE1TmlBeE56Y3VNak0xSURFeU1DNHdPRll4TkRNdU1USmFUVEUzTVM0M09UVWdNVEU0TGpnMk5FTXhOekV1TnprMUlERXhOeTQxTkRFZ01UY3hMakk0TXlBeE1UWXVOREV4SURFM01DNHlOVGtnTVRFMUxqUTNNa014TmprdU1qYzNJREV4TkM0ME9URWdNVFk0TGpBeE9TQXhNVFFnTVRZMkxqUTRNeUF4TVRSSU1UWTFMakl3TTBNeE5qTXVOalkzSURFeE5DQXhOakl1TXpnM0lERXhOQzQwT1RFZ01UWXhMak0yTXlBeE1UVXVORGN5UXpFMk1DNHpPREVnTVRFMkxqUXhNU0F4TlRrdU9Ea3hJREV4Tnk0MU5ERWdNVFU1TGpnNU1TQXhNVGd1T0RZMFZqRXpOaTR5TURoTU1UY3hMamM1TlNBeE1UZ3VPRFkwV2sweE5Ua3VPRGt4SURFME5DNHpNelpETVRVNUxqZzVNU0F4TkRVdU5qVTVJREUyTUM0ek9ERWdNVFEyTGpneE1TQXhOakV1TXpZeklERTBOeTQzT1RKRE1UWXlMak00TnlBeE5EZ3VOek14SURFMk15NDJOamNnTVRRNUxqSWdNVFkxTGpJd015QXhORGt1TWtneE5qWXVORGd6UXpFMk9DNHdNVGtnTVRRNUxqSWdNVFk1TGpJM055QXhORGd1TnpNeElERTNNQzR5TlRrZ01UUTNMamM1TWtNeE56RXVNamd6SURFME5pNDRNVEVnTVRjeExqYzVOU0F4TkRVdU5qVTVJREUzTVM0M09UVWdNVFEwTGpNek5sWXhNamN1TURVMlRERTFPUzQ0T1RFZ01UUTBMak16TmxwTk1qQXdMakkzTnlBeE16VXVPREkwVERFNU5pNHlORFVnTVRVMFNERTRPQzQxTmpWTU1UZzJMak00T1NBeE1Ea3VNa2d4T1RFdU1USTFUREU1TXk0d05EVWdNVFE1TGpKTU1UazRMak0xTnlBeE1qZ3VNRGhJTWpBeUxqTXlOVXd5TURjdU56WTFJREUwT1M0eVRESXdPUzQzTkRrZ01UQTVMakpJTWpFMExqRTJOVXd5TVRFdU9UZzVJREUxTkVneU1ETXVPVEkxVERJd01DNHlOemNnTVRNMUxqZ3lORnBOTWpRMExqVXdOQ0F4TkRNdU9EZzRRekkwTkM0MU1EUWdNVFEzTGpReU9TQXlORE11TmpVZ01UVXdMakF4TVNBeU5ERXVPVFEwSURFMU1TNDJNekpETWpRd0xqSXpOeUF4TlRNdU1qRXhJREl6Tnk0ME5qUWdNVFUwSURJek15NDJNalFnTVRVMFNESXlOUzQwTXpKV01UUTVMakpJTWpNMExqSkRNak0xTGpneU1TQXhORGt1TWlBeU16Y3VNREUySURFME9DNDRNemNnTWpNM0xqYzROQ0F4TkRndU1URXlRekl6T0M0MU5USWdNVFEzTGpNME5DQXlNemd1T1RNMklERTBOaTR4TkRrZ01qTTRMamt6TmlBeE5EUXVOVEk0VmpFek55NDVNelpETWpNNExqa3pOaUF4TXpZdU5USTRJREl6T0M0MU1Ea2dNVE0xTGpReE9TQXlNemN1TmpVMklERXpOQzQyTURoRE1qTTJMamd3TWlBeE16TXVOelUxSURJek5TNDJOeklnTVRNekxqTXlPQ0F5TXpRdU1qWTBJREV6TXk0ek1qaElNakkzTGpReE5sWXhNamd1TlRJNFNESXpNeTQyTWpSRE1qTTBMamswTmlBeE1qZ3VOVEk0SURJek5pNHdOVFlnTVRJNExqRXdNU0F5TXpZdU9UVXlJREV5Tnk0eU5EaERNak0zTGpnME9DQXhNall1TXprMUlESXpPQzR5T1RZZ01USTFMakkyTkNBeU16Z3VNamsySURFeU15NDROVFpXTVRFNExqWXdPRU15TXpndU1qazJJREV4Tmk0NU9EY2dNak0zTGpreE1pQXhNVFV1T0RFeklESXpOeTR4TkRRZ01URTFMakE0T0VNeU16WXVOREU0SURFeE5DNHpOak1nTWpNMUxqSTBOU0F4TVRRZ01qTXpMall5TkNBeE1UUklNakkxTGpRek1sWXhNRGt1TWtneU16SXVPRFUyUXpJek5pNDBPRElnTVRBNUxqSWdNak01TGpJeE15QXhNVEF1TURFeElESTBNUzR3TkRnZ01URXhMall6TWtNeU5ESXVPVEkxSURFeE15NHlNVEVnTWpRekxqZzJOQ0F4TVRVdU56STRJREkwTXk0NE5qUWdNVEU1TGpFNE5GWXhNak11TWpFMlF6STBNeTQ0TmpRZ01USTJMalV3TVNBeU5ESXVOamtnTVRJNExqazNOaUF5TkRBdU16UTBJREV6TUM0Mk5FTXlORE11TVRFM0lERXpNaTR4TnpZZ01qUTBMalV3TkNBeE16UXVPQ0F5TkRRdU5UQTBJREV6T0M0MU1USldNVFF6TGpnNE9Gb2lJR1pwYkd3OUluZG9hWFJsSWo0OEwzQmhkR2crUEM5emRtYysiLCJleHRlcm5hbF9saW5rIjoiaHR0cHM6Ly90d2l0dGVyLmNvbS93c2x5dmgiLCJmZWVfcmVjaXBpZW50IjoiMHg2M2NhYjY5MTg5ZEJhMmYxNTQ0YTI1YzhDMTliNDMwOWY0MTVjOEFBIiwic2VsbGVyX2ZlZV9iYXNpc19wb2ludHMiOjB9";
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
