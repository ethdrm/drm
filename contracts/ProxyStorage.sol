pragma solidity ^0.4.8;

import './Mortal.sol';

contract ProxyStorage is Mortal {
    mapping(bytes4=>uint32) public sizes;
    address public target;

    function ProxyStorage() {
    }

    function registerSize(bytes4 signature, uint32 retsize) {
        sizes[signature] = retsize;
    }

    function migrate(address newTarget) {
        target = newTarget;
    }
}
