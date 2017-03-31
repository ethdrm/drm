pragma solidity ^0.4.8;

import "./Discount.sol";
import "./Mortal.sol";

contract DiscountRegistry is Mortal {

  mapping(address => bool) private discounts;

  function register(address discount) onlyOwner {
    discounts[discount] = true;
  }

  function deregister(address discount) onlyOwner {
    discounts[discount] = false;
  }

  function get(address discountAddr) returns (Discount, bool) {
    if (!discounts[discountAddr]) {
      return (Discount(0x0), true);
    }
    return (Discount(discountAddr), false);
  }
}