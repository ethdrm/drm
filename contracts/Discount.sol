pragma solidity ^0.4.8;

contract Discount {
  function register();
  function unregister();
  function apply(uint total, address[] to, uint[] amount) returns (uint);
}