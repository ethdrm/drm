pragma solidity ^0.4.5;

import "Drm.sol";

contract Discount {
  function register();
  function unregister();
  function apply(uint total, address[] to, uint[] amount) returns (uint);
}
