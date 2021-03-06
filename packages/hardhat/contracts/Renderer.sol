// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.6.0 <0.9.0;

// Thank you OpenZeppelin
import "@openzeppelin/contracts/utils/Strings.sol";

// Thank you tangert
// https://gist.github.com/tangert/1eceaf04f2877d84fb0e10681b39d7e3#file-renderer-sol

// Thanks GeeksForGeeks
// https://www.geeksforgeeks.org/random-number-generator-in-solidity-using-keccak256/

contract Renderer {
    constructor() {}

    function _render(uint256 id, string memory cohort)
        public
        pure
        returns (string memory)
    {
        string memory gradientStart = string(
            abi.encodePacked(
                "hsla(",
                Strings.toString(generateHighlightHue(id)),
                ", 100%, 50%, 1)"
            )
        );
        string memory gradientEnd = "hsla(250, 64%, 45%, 1)";
        string memory allGradients = renderAllGradients(
            gradientEnd,
            gradientStart
        );
        return
            string(
                abi.encodePacked(
                    '<svg width="500" height="500" viewBox="0 0 500 500" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="0.5" y="3.5" width="496" height="496" rx="41.5" fill="#8F8F8F" stroke="#838383" /><rect x="7.5" y="0.5" width="492" height="493" rx="41.5" fill="#EFEFEF" stroke="#C0C0C0" /><text x="352" y="64" fill="url(#titleGradient)" font-size="48px" font-weight="900" line-height="58px" letter-spacing="-2px" font-family="Inter,Arial,Helvetica,Apple Color Emoji,Segoe UI Emoji,NotoColorEmoji,Noto Color Emoji,Segoe UI Symbol,Android Emoji,EmojiSymbols,-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica Neue,Noto Sans,sans-serif">30W3</text><text x="34" y="442" fill="url(#graduationGradient)" font-size="28px" font-weight="800" line-height="29px" letter-spacing="-1px" font-family="Inter,Arial,Helvetica,Apple Color Emoji,Segoe UI Emoji,NotoColorEmoji,Noto Color Emoji,Segoe UI Symbol,Android Emoji,EmojiSymbols,-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica Neue,Noto Sans,sans-serif">Graduation</text><text x="34" y="464" fill="#29295E" font-size="22px" font-weight="bold" line-height="22px" letter-spacing="-1px" font-family="Inter,Arial,Helvetica,Apple Color Emoji,Segoe UI Emoji,NotoColorEmoji,Noto Color Emoji,Segoe UI Symbol,Android Emoji,EmojiSymbols,-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica Neue,Noto Sans,sans-serif">',
                    cohort,
                    '</text><path id="diskEye" d="M250 156.975C196.884 156.975 147.486 188.44 131.859 238.309C142.609 285.427 196.884 319.642 250 319.642C303.116 319.642 354.992 288.177 368.141 238.309C352.332 188.44 303.116 156.975 250 156.975Z" fill="url(#diskEyeGradient)" /><path id="diskBottom" d="M250 316.642C196.884 316.642 151.313 284.34 131.859 238.309C125.381 253.638 121.798 270.489 121.798 288.177C121.798 358.982 179.196 416.38 250 416.38C320.804 416.38 378.202 358.982 378.202 288.177C378.202 270.489 374.62 253.638 368.141 238.309C348.687 284.34 303.116 316.642 250 316.642Z" fill="url(#diskBottomGradient)" /><path id="diskTop" d="M250 159.975C303.116 159.975 348.687 192.277 368.141 238.309C374.62 222.98 378.202 206.128 378.202 188.44C378.202 117.636 320.804 60.2375 250 60.2375C179.196 60.2375 121.798 117.636 121.798 188.44C121.798 206.128 125.381 222.98 131.859 238.309C151.313 192.277 196.884 159.975 250 159.975Z" fill="url(#diskTopGradient)" /><path id="diskPupil" d="M250 288.177C277.542 288.177 299.869 265.85 299.869 238.309C299.869 210.767 277.542 188.44 250 188.44C222.458 188.44 200.131 210.767 200.131 238.309C200.131 265.85 222.458 288.177 250 288.177Z" fill="url(#diskPupilGradient)" /><defs>',
                    allGradients,
                    '<linearGradient id="diskPupilGradient" x1="213.346" y1="202.702" x2="283.18" y2="270.54" gradientUnits="userSpaceOnUse"><stop stop-color="white" stop-opacity="0.8" /><stop offset="1" stop-color="white" stop-opacity="0.4" /></linearGradient></defs></svg>'
                )
            );
    }

    function renderGradient(
        string memory gradientStart,
        string memory gradientEnd,
        string memory id,
        string memory x1,
        string memory y1,
        string memory x2,
        string memory y2
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<linearGradient id="',
                    id,
                    '" x1="',
                    x1,
                    '" y1="',
                    y1,
                    '" x2="',
                    x2,
                    '" y2="',
                    y2,
                    '"  gradientUnits="userSpaceOnUse">',
                    '<stop stop-color="',
                    gradientStart,
                    '" /><stop offset="1" stop-color="',
                    gradientEnd,
                    '" /></linearGradient>'
                )
            );
    }

    function renderAllGradients(
        string memory gradientStart,
        string memory gradientEnd
    ) private pure returns (string memory) {
        string memory titleGradient = renderGradient(
            gradientStart,
            gradientEnd,
            "titleGradient",
            "352",
            "452",
            "64",
            "100"
        );
        string memory graduationGradient = renderGradient(
            gradientStart,
            gradientEnd,
            "graduationGradient",
            "34",
            "170",
            "442",
            "472"
        );
        string memory diskEyeGradient = renderGradient(
            gradientEnd,
            gradientStart,
            "diskEyeGradient",
            "379.203",
            "80.7484",
            "144.731",
            "367.874"
        );
        string memory diskBottomGradient = renderGradient(
            gradientEnd,
            gradientStart,
            "diskBottomGradient",
            "360.817",
            "349.878",
            "132.361",
            "268.073"
        );
        string memory diskTopGradient = renderGradient(
            gradientEnd,
            gradientStart,
            "diskTopGradient",
            "138.53",
            "119.249",
            "372.108",
            "225.058"
        );
        return
            string(
                abi.encodePacked(
                    titleGradient,
                    graduationGradient,
                    diskEyeGradient,
                    diskBottomGradient,
                    diskTopGradient
                )
            );
    }

    // In HSL color mode, the "H" parameters varies from 0 to 359
    function generateHighlightHue(uint256 id) private pure returns (uint256) {
        return
            uint256(keccak256(abi.encodePacked(id, "somesaltysalt", id))) % 359;
    }
}
