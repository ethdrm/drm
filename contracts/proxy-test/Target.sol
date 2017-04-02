pragma solidity ^0.4.8;

import "./TargetInterface.sol";

contract Target {
    uint public number;

    function Target() {
        // warning: never set values in constructor, they won't be visible 
        // in proxy (cause it executes delegatecall and we're using proxy context)
    }

    function setNumber(uint _number) {
        number = _number;
    }

    function getNumber() payable returns(uint) {
        return number;
    }
}