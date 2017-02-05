pragma solidity ^0.4.5;

import "ArrayUtils.sol";
import "FunctionUtils.sol";
import "Discount.sol";


contract Drm {
  using ArrayUtils for *;

  mapping(address => uint) public licences;
  mapping(address => bool) public blacklist;
  mapping(address => bool) public discounts;

  address public owner;
  uint public price;
  uint transferFee;

  event LicenceBought(address[] to, uint[] amount);
  event LicenceTransfered(address from, address to, uint amount);
  event LicenceRevoked(address customer, uint amount, string reason);

  event DiscountAdded(address discount);
  event DiscountRemoved(address discount);

  event CustomerBanned(address customer, string reason);

  event PriceChanged(uint oldPrice, uint newPrice);
  event TransferFeeChanged(uint oldPrice, uint newPrice);

  event DepositeReceived(address sender, uint amount);

  modifier onlyOwner() {
    if (msg.sender != owner) throw;
    _;
  }

  modifier costs(uint cost) {
    if (msg.value < cost) throw;
    _;
  }

  function Drm(uint startPrice, uint startTransferFee) {
    owner = msg.sender;
    price = startPrice;
    transferFee = startTransferFee;
  }

  function() payable {
    DepositeReceived(msg.sender, msg.value);
  }

  function buy(
    address[] to,
    uint[] amount,
    address[] discounts
  ) payable {
    if (to.length != amount.length) throw;

    uint total = 0;
    for (uint i = 0; i < to.length; i++) {
      if (blacklist[to[i]]) throw;
      total += price * amount[i];
    }

    for (uint j = 0; j < discounts.length; j++) {
      total = applyDiscount(discounts[i], total, to, amount);
    }
    if (msg.value < total) throw;

    for (i = 0; i < to.length; i++) {
      licences[to[i]] += amount[i];
    }

    LicenceBought(to, amount);
  }

  function transfer(address from, address to, uint amount) costs(transferFee) {
    if (licences[from] < amount) throw;
    licences[from] -= amount;
    licences[to] += amount;

    LicenceTransfered(from, to, amount);
  }

  function revoke(
    address customer,
    uint amount,
    string reason
  ) onlyOwner {
    if (licences[customer] < amount) throw;
    licences[customer] -= amount;

    LicenceRevoked(customer, amount, reason);
  }

  function ban(address customer, string reason) onlyOwner {
    blacklist[customer] = true;

    CustomerBanned(customer, reason);
  }

  function changePrice(uint newPrice) onlyOwner {
    uint oldPrice = price;
    price = newPrice;

    PriceChanged(oldPrice, newPrice);
  }

  function changeTransferFee(uint newTransferFee) onlyOwner {
    uint oldTransferFee = transferFee;
    transferFee = newTransferFee;

    TransferFeeChanged(oldTransferFee, newTransferFee);
  }

  function checkLicence(address customer, uint amount) returns (bool) {
    return licences[customer] >= amount;
  }

  function registerDiscount(address discount) onlyOwner {
    discounts[discount] = true;

    DiscountAdded(discount);
  }

  function unregisterDiscount(address discount) onlyOwner {
    discounts[discount] = false;

    DiscountRemoved(discount);
  }

  function kill() onlyOwner {
    selfdestruct(owner);
  }

  function applyDiscount(
    address discountAddress,
    uint total,
    address[] to,
    uint[] amount
  )
    internal returns (uint) {
    if (!discounts[discount]) {
      return total;
    }
    Discount discount = Discount(discountAddress);
    return discount.apply(total, to, amount);
  }
}
