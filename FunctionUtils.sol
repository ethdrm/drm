pragma solidity ^0.4.5;

library FunctionUtils {
  function sum(uint x, uint y) internal returns(uint) {
    return x + y;
  }

  function mult(uint x, uint y) internal returns (uint) {
    return y * x;
  }

  function div(uint x, uint y) internal returns(uint) {
    return x / y;
  }

  function diff(uint x, uint y) internal returns(uint) {
    return x - y;
  }
}
