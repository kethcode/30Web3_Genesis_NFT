// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

/*
* @author: kethcode
*/

/// ----------------------------------------------------------------------------
/// Errors
/// ----------------------------------------------------------------------------

error NotAdmin();

abstract contract Adminlist {

    /// ------------------------------------------------------------------------
    /// Events
    /// ------------------------------------------------------------------------

    event AdminAddressAdded(address addr);
    event AdminAddressRemoved(address addr);

    /// ------------------------------------------------------------------------
    /// Variables
    /// ------------------------------------------------------------------------

    mapping(address => bool) public adminlist;

    /// ------------------------------------------------------------------------
    /// Modifiers
    /// ------------------------------------------------------------------------

    modifier onlyAdmin()
    {
        if(!adminlist[msg.sender]) revert NotAdmin();
        _;
    }

    /// ------------------------------------------------------------------------
    /// Functions
    /// ------------------------------------------------------------------------

    function addAddressToAdminlist(address addr) 
        public 
        onlyAdmin
        returns(bool success) 
    {
        if (!adminlist[addr]) {
            adminlist[addr] = true;
            emit AdminAddressAdded(addr);
            success = true; 
        }
    }

    function removeAddressFromAdminlist(address addr) 
        public 
        onlyAdmin
        returns(bool success) 
    {
        if (adminlist[addr]) {
            adminlist[addr] = false;
            emit AdminAddressRemoved(addr);
            success = true;
        }
    }

    function _setupAdmin(address addr) 
        internal 
        virtual 
    {
        adminlist[addr] = true;
        emit AdminAddressAdded(addr);
    }
}