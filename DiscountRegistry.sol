pragma solidity ^0.4.9;

import "Discount.sol";

contract DiscountRegistry {

  mapping(address => bool) private discounts;

  function register(address discount) {
    discounts[discount] = true;
  }

  function unregister(address discount) {
    discounts[discount] = false;
  }

  function get(address discountAddr) returns (Discount discount, bool error) {
    if (!discounts[discountAddr]) {
      return (Discount(0x0), true);
    }
    return (Discount(discountAddr), false);
  }
}
