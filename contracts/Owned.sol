pragma solidity ^0.4.8;

contract Owned {

    address internal owner;

    function Owned() {
        // owner is not initiated in constrcted due to usage of proxy
    }

    function setOwner(address _owner) {
        if (owner == 0x0 || msg.sender == owner) {
            owner = _owner;
        }
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }
}