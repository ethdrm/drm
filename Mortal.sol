pragma solidity ^0.4.9;

contract Mortal {
  
  address internal owner;

  function kill() {
    if (msg.sender == owner) {
      selfdestruct(owner);
    }
  }

  function Mortal() {
    owner = msg.sender;
  }
}
