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

import "@openzeppelin/contracts/interfaces/IERC20.sol";

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
        "30Web3 Graduates",
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
        return buildSvg("30Web3", "Congratulations on your successful completion of 30Web3!", svgString);
    }

    function contractURI()
        public
        pure 
        returns (string memory) 
    {
        return "data:application/json;base64,eyJuYW1lIjoiMzBXZWIzIEdyYWR1YXRlcyIsImRlc2NyaXB0aW9uIjoiMzAgZGF5cyBvZiBXZWIzIGlzIGFuIG9wcG9ydHVuaXR5IHRvIHdvcmsgd2l0aCB5b3VyIHBlZXJzLCBzaGlwIGEgcHJvamVjdCwgYW5kIGdhaW4gaGFuZHMtb24gV2ViMyBleHBlcmllbmNlIGluIHNtYWxsLCBjb2xsYWJvcmF0aXZlLCBmb2N1c2VkIGNvaG9ydHMuIFRoZXNlIHRva2VucyBjb21tZW1vcmF0ZSB0aGUgZ3JhZHVhdGVzIGZyb20gZWFjaCBjb2hvcnQuIiwiaW1hZ2UiOiAiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4yWnlCM2FXUjBhRDBpTlRSd2VDSWdhR1ZwWjJoMFBTSTBNSEI0SWlCMmFXVjNRbTk0UFNJd0lEQWdNelkySURJMk5pSWdabWxzYkQwaWJtOXVaU0lnZUcxc2JuTTlJbWgwZEhBNkx5OTNkM2N1ZHpNdWIzSm5Mekl3TURBdmMzWm5JajQ4Wld4c2FYQnpaU0JqZUQwaU1UTXlJaUJqZVQwaU1UTXpMalVpSUhKNFBTSXhNeklpSUhKNVBTSXhNekl1TlNJZ1ptbHNiRDBpSTBaR01EQTJSaUkrUEM5bGJHeHBjSE5sUGp4bklITjBlV3hsUFNKdGFYZ3RZbXhsYm1RdGJXOWtaVG9nWTI5c2IzSXRaRzlrWjJVN0lqNDhaV3hzYVhCelpTQmplRDBpTWpNMElpQmplVDBpTVRNeUxqVWlJSEo0UFNJeE16SWlJSEo1UFNJeE16SXVOU0lnWm1sc2JEMGlkMmhwZEdVaVBqd3ZaV3hzYVhCelpUNDhMMmMrUEhCaGRHZ2dabWxzYkMxeWRXeGxQU0psZG1WdWIyUmtJaUJqYkdsd0xYSjFiR1U5SW1WMlpXNXZaR1FpSUdROUlrMHhPREV1T0RFeUlERXdMamMxT0RkRE1qTXdMakF5TWlBek1DNDBPVEl5SURJMk5DQTNPQzR3TVRNeElESTJOQ0F4TXpNdU5VTXlOalFnTVRnNExqQTNNU0F5TXpFdU1UTTFJREl6TkM0NU16Y2dNVGcwTGpFNE9DQXlOVFV1TWpReFF6RXpOUzQ1TnpnZ01qTTFMalV3T0NBeE1ESWdNVGczTGprNE55QXhNRElnTVRNeUxqVkRNVEF5SURjM0xqa3lPVElnTVRNMExqZzJOU0F6TVM0d05qTTFJREU0TVM0NE1USWdNVEF1TnpVNE4xb2lJR1pwYkd3OUlpTkdSakF3UmtZaVBqd3ZjR0YwYUQ0OFkybHlZMnhsSUdONFBTSXhPRE1pSUdONVBTSXhNeklpSUhJOUlqZ3hJaUJtYVd4c1BTSWpPRFF6T1VWRUlqNDhMMk5wY21Oc1pUNDhjR0YwYUNCa1BTSk5NVFF3TGpneE5pQXhORE11T0RnNFF6RTBNQzQ0TVRZZ01UUTNMalF5T1NBeE16a3VPVFl6SURFMU1DNHdNVEVnTVRNNExqSTFOaUF4TlRFdU5qTXlRekV6Tmk0MU5Ea2dNVFV6TGpJeE1TQXhNek11TnpjMklERTFOQ0F4TWprdU9UTTJJREUxTkVneE1qRXVOelEwVmpFME9TNHlTREV6TUM0MU1USkRNVE15TGpFek15QXhORGt1TWlBeE16TXVNekk0SURFME9DNDRNemNnTVRNMExqQTVOaUF4TkRndU1URXlRekV6TkM0NE5qUWdNVFEzTGpNME5DQXhNelV1TWpRNElERTBOaTR4TkRrZ01UTTFMakkwT0NBeE5EUXVOVEk0VmpFek55NDVNelpETVRNMUxqSTBPQ0F4TXpZdU5USTRJREV6TkM0NE1qRWdNVE0xTGpReE9TQXhNek11T1RZNElERXpOQzQyTURoRE1UTXpMakV4TlNBeE16TXVOelUxSURFek1TNDVPRFFnTVRNekxqTXlPQ0F4TXpBdU5UYzJJREV6TXk0ek1qaElNVEl6TGpjeU9GWXhNamd1TlRJNFNERXlPUzQ1TXpaRE1UTXhMakkxT1NBeE1qZ3VOVEk0SURFek1pNHpOamdnTVRJNExqRXdNU0F4TXpNdU1qWTBJREV5Tnk0eU5EaERNVE0wTGpFMklERXlOaTR6T1RVZ01UTTBMall3T0NBeE1qVXVNalkwSURFek5DNDJNRGdnTVRJekxqZzFObFl4TVRndU5qQTRRekV6TkM0Mk1EZ2dNVEUyTGprNE55QXhNelF1TWpJMElERXhOUzQ0TVRNZ01UTXpMalExTmlBeE1UVXVNRGc0UXpFek1pNDNNekVnTVRFMExqTTJNeUF4TXpFdU5UVTNJREV4TkNBeE1qa3VPVE0ySURFeE5FZ3hNakV1TnpRMFZqRXdPUzR5U0RFeU9TNHhOamhETVRNeUxqYzVOU0F4TURrdU1pQXhNelV1TlRJMUlERXhNQzR3TVRFZ01UTTNMak0ySURFeE1TNDJNekpETVRNNUxqSXpOeUF4TVRNdU1qRXhJREUwTUM0eE56WWdNVEUxTGpjeU9DQXhOREF1TVRjMklERXhPUzR4T0RSV01USXpMakl4TmtNeE5EQXVNVGMySURFeU5pNDFNREVnTVRNNUxqQXdNeUF4TWpndU9UYzJJREV6Tmk0Mk5UWWdNVE13TGpZMFF6RXpPUzQwTWprZ01UTXlMakUzTmlBeE5EQXVPREUySURFek5DNDRJREUwTUM0NE1UWWdNVE00TGpVeE1sWXhORE11T0RnNFdrMHhOemN1TWpNMUlERTBNeTR4TWtNeE56Y3VNak0xSURFME5pNDJOakVnTVRjMkxqSTFNeUF4TkRrdU16Y3hJREUzTkM0eU9URWdNVFV4TGpJME9FTXhOekl1TXpjeElERTFNeTR3T0RNZ01UWTVMamMyT0NBeE5UUWdNVFkyTGpRNE15QXhOVFJJTVRZMUxqSXdNME14TmpFdU9URTNJREUxTkNBeE5Ua3VNamt6SURFMU15NHdPRE1nTVRVM0xqTXpNU0F4TlRFdU1qUTRRekUxTlM0ME1URWdNVFE1TGpNM01TQXhOVFF1TkRVeElERTBOaTQyTmpFZ01UVTBMalExTVNBeE5ETXVNVEpXTVRJd0xqQTRRekUxTkM0ME5URWdNVEUyTGpRNU5pQXhOVFV1TkRFeElERXhNeTQzT0RjZ01UVTNMak16TVNBeE1URXVPVFV5UXpFMU9TNHlOVEVnTVRFd0xqRXhOeUF4TmpFdU9EYzFJREV3T1M0eUlERTJOUzR5TURNZ01UQTVMakpJTVRZMkxqUTRNME14TmprdU9ERXhJREV3T1M0eUlERTNNaTQwTXpVZ01URXdMakV4TnlBeE56UXVNelUxSURFeE1TNDVOVEpETVRjMkxqSTNOU0F4TVRNdU56ZzNJREUzTnk0eU16VWdNVEUyTGpRNU5pQXhOemN1TWpNMUlERXlNQzR3T0ZZeE5ETXVNVEphVFRFM01TNDNPVFVnTVRFNExqZzJORU14TnpFdU56azFJREV4Tnk0MU5ERWdNVGN4TGpJNE15QXhNVFl1TkRFeElERTNNQzR5TlRrZ01URTFMalEzTWtNeE5qa3VNamMzSURFeE5DNDBPVEVnTVRZNExqQXhPU0F4TVRRZ01UWTJMalE0TXlBeE1UUklNVFkxTGpJd00wTXhOak11TmpZM0lERXhOQ0F4TmpJdU16ZzNJREV4TkM0ME9URWdNVFl4TGpNMk15QXhNVFV1TkRjeVF6RTJNQzR6T0RFZ01URTJMalF4TVNBeE5Ua3VPRGt4SURFeE55NDFOREVnTVRVNUxqZzVNU0F4TVRndU9EWTBWakV6Tmk0eU1EaE1NVGN4TGpjNU5TQXhNVGd1T0RZMFdrMHhOVGt1T0RreElERTBOQzR6TXpaRE1UVTVMamc1TVNBeE5EVXVOalU1SURFMk1DNHpPREVnTVRRMkxqZ3hNU0F4TmpFdU16WXpJREUwTnk0M09USkRNVFl5TGpNNE55QXhORGd1TnpNeElERTJNeTQyTmpjZ01UUTVMaklnTVRZMUxqSXdNeUF4TkRrdU1rZ3hOall1TkRnelF6RTJPQzR3TVRrZ01UUTVMaklnTVRZNUxqSTNOeUF4TkRndU56TXhJREUzTUM0eU5Ua2dNVFEzTGpjNU1rTXhOekV1TWpneklERTBOaTQ0TVRFZ01UY3hMamM1TlNBeE5EVXVOalU1SURFM01TNDNPVFVnTVRRMExqTXpObFl4TWpjdU1EVTJUREUxT1M0NE9URWdNVFEwTGpNek5scE5NakF3TGpJM055QXhNelV1T0RJMFRERTVOaTR5TkRVZ01UVTBTREU0T0M0MU5qVk1NVGcyTGpNNE9TQXhNRGt1TWtneE9URXVNVEkxVERFNU15NHdORFVnTVRRNUxqSk1NVGs0TGpNMU55QXhNamd1TURoSU1qQXlMak15TlV3eU1EY3VOelkxSURFME9TNHlUREl3T1M0M05Ea2dNVEE1TGpKSU1qRTBMakUyTlV3eU1URXVPVGc1SURFMU5FZ3lNRE11T1RJMVRESXdNQzR5TnpjZ01UTTFMamd5TkZwTk1qUTBMalV3TkNBeE5ETXVPRGc0UXpJME5DNDFNRFFnTVRRM0xqUXlPU0F5TkRNdU5qVWdNVFV3TGpBeE1TQXlOREV1T1RRMElERTFNUzQyTXpKRE1qUXdMakl6TnlBeE5UTXVNakV4SURJek55NDBOalFnTVRVMElESXpNeTQyTWpRZ01UVTBTREl5TlM0ME16SldNVFE1TGpKSU1qTTBMakpETWpNMUxqZ3lNU0F4TkRrdU1pQXlNemN1TURFMklERTBPQzQ0TXpjZ01qTTNMamM0TkNBeE5EZ3VNVEV5UXpJek9DNDFOVElnTVRRM0xqTTBOQ0F5TXpndU9UTTJJREUwTmk0eE5Ea2dNak00TGprek5pQXhORFF1TlRJNFZqRXpOeTQ1TXpaRE1qTTRMamt6TmlBeE16WXVOVEk0SURJek9DNDFNRGtnTVRNMUxqUXhPU0F5TXpjdU5qVTJJREV6TkM0Mk1EaERNak0yTGpnd01pQXhNek11TnpVMUlESXpOUzQyTnpJZ01UTXpMak15T0NBeU16UXVNalkwSURFek15NHpNamhJTWpJM0xqUXhObFl4TWpndU5USTRTREl6TXk0Mk1qUkRNak0wTGprME5pQXhNamd1TlRJNElESXpOaTR3TlRZZ01USTRMakV3TVNBeU16WXVPVFV5SURFeU55NHlORGhETWpNM0xqZzBPQ0F4TWpZdU16azFJREl6T0M0eU9UWWdNVEkxTGpJMk5DQXlNemd1TWprMklERXlNeTQ0TlRaV01URTRMall3T0VNeU16Z3VNamsySURFeE5pNDVPRGNnTWpNM0xqa3hNaUF4TVRVdU9ERXpJREl6Tnk0eE5EUWdNVEUxTGpBNE9FTXlNell1TkRFNElERXhOQzR6TmpNZ01qTTFMakkwTlNBeE1UUWdNak16TGpZeU5DQXhNVFJJTWpJMUxqUXpNbFl4TURrdU1rZ3lNekl1T0RVMlF6SXpOaTQwT0RJZ01UQTVMaklnTWpNNUxqSXhNeUF4TVRBdU1ERXhJREkwTVM0d05EZ2dNVEV4TGpZek1rTXlOREl1T1RJMUlERXhNeTR5TVRFZ01qUXpMamcyTkNBeE1UVXVOekk0SURJME15NDROalFnTVRFNUxqRTRORll4TWpNdU1qRTJRekkwTXk0NE5qUWdNVEkyTGpVd01TQXlOREl1TmprZ01USTRMamszTmlBeU5EQXVNelEwSURFek1DNDJORU15TkRNdU1URTNJREV6TWk0eE56WWdNalEwTGpVd05DQXhNelF1T0NBeU5EUXVOVEEwSURFek9DNDFNVEpXTVRRekxqZzRPRm9pSUdacGJHdzlJbmRvYVhSbElqNDhMM0JoZEdnK1BDOXpkbWMrIiwiZXh0ZXJuYWxfbGluayI6Imh0dHBzOi8vdHdpdHRlci5jb20vd3NseXZoIiwiZmVlX3JlY2lwaWVudCI6IjB4NjNjYWI2OTE4OWRCYTJmMTU0NGEyNWM4QzE5YjQzMDlmNDE1YzhBQSIsInNlbGxlcl9mZWVfYmFzaXNfcG9pbnRzIjowfQ==";
    }

    function withdraw()
        public
        onlyAdmin
    {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function withdrawTokens(
        IERC20 token
    )
        public
        onlyAdmin 
    {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
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
