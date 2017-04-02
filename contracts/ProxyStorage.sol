pragma solidity ^0.4.8;

contract ProxyStorage {
    mapping(bytes4=>uint32) public sizes;
    address public target;

    function ProxyStorage(address _target) {
        target = _target;
    }

    function registerSize(bytes4 signature, uint32 retsize) {
        sizes[signature] = retsize;
    }

    function migrate(address newTarget) {
        target = newTarget;
    }
}
