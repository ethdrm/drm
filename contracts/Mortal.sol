pragma solidity ^0.4.8;

import "./Owned.sol";

contract Mortal is Owned {
  function kill() onlyOwner {
      selfdestruct(owner);
  }
}