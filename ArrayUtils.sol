pragma solidity ^0.4.0;

library ArrayUtils {
  function map(uint[] memory before, function (uint) returns (uint) f)
  internal
  returns (uint[] memory after)
  {
    after = new uint[](before.length);
    for (uint i = 0; i < before.length; i++) {
      after[i] = f(before[i]);
    }
  }

  function reduce(
    uint[] memory before,
    function(uint x, uint y) returns(uint) f
    )
      internal
      returns(uint result)
    {
      result = before[0];
      for (uint i = 1; i < before.length; i++) {
        result = f(result, before[i]);
      }
    }

  function range(uint length) internal returns (uint[] memory r) {
    r = new uint[](length);
    for (uint i = 0; i < r.length; i++) {
      r[i] = i;
    }
  }
}
