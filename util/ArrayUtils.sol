pragma solidity ^0.4.5;

library ArrayUtils {
  function map(
    uint[] memory before,
    function (uint) returns (uint) f
  )
    internal returns (uint[] memory result) {
      result = new uint[](before.length);
      for (uint i = 0; i < result.length; i++) {
        result[i] = f(before[i]);
      }
  }

  function reduce(
    uint[] memory before,
    function (uint, uint) returns (uint) f
  )
    internal returns (uint result) {
      result = before[0];
      for (uint i = 0; i < before.length; i++) {
        result = f(result, before[i]);
      }
  }

  function range(uint length)
    internal returns (uint[] memory result) {
      result = new uint[](length);
      for (uint i = 0; i < result.length; i++) {
        result[i] = i;
      }
    }
}
