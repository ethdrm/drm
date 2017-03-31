pragma solidity ^0.4.8;

contract Owned {

    address internal owner;

    function Owned() {
        owner = tx.origin;
    }

    modifier onlyOwner {
        if (tx.origin != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}