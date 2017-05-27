pragma solidity ^0.4.8;

contract Discount {
  
  enum ClientAction { PURCHASE, TRANSFER }

  function register();
  function unregister();
  function apply(uint total, uint amount, ClientAction action) returns (uint);
}