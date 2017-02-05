pragma solidity ^0.4.5;

import "ArrayUtils.sol";
import "FunctionUtils.sol";
import "Discount.sol";


contract Drm {
  using ArrayUtils for *;

  struct LicenceRequest {
    address customer;
    uint amount;
  }

  mapping(address => uint) public licences;
  mapping(address => bool) public blacklist;
  mapping(address => bool) public discounts;

  address public owner;
  uint public price;
  uint transferFee;

  event LicenceBought(address customer, uint amount);
  event LicenceTransfered(address from, address to, uint amount);
  event LicenceRevoked(address customer, uint amount, string reason);

  event DiscountAdded(Discount discount);
  event DiscountRemoved(Discount discount);

  event CustomerBanned(address customer, string reason);

  event PriceChanged(uint oldPrice, uint newPrice);
  event TransferFeeChanged(uint oldPrice, uint newPrice);

  event DepositeReceived(address sender, uint amount);

  modifier onlyOwner() {
    if (msg.sender != owner) throw;
    _;
  }

  modifier costs(LicenceRequest[] requests, address[] discounts) {
    uint total = 0;
    for (uint i = 0; i < requests.length; i++) {
      total += price * requests[i].amount;
    }
    for (i = 0; i < discounts.length; i++) {
      total = applyDiscount(discounts[i], total, requests);
    }
    if (msg.value < total) throw;
    _;
  }

  modifier notBlacklisted() {
    if (blacklist[msg.sender]) throw;
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

  function buyLicence(
    LicenceRequest request,
    address[] discounts
  )
    payable
    notBlacklisted(request.customer)
    costs([request], discounts) {
    licences[request.customer] += 1;

    LicenceBought(request);
  }

  function buyLicences(
    LicenceRequest[] requests,
    address[] discounts
  )
    payable
    costs(requests, discounts) {
    for (uint i = 0; i < requests.length; i++) {
      if (blacklist[requests[i].customer]) throw;
      licences[requests[i].customer] += requests[i].amount;
    }
  }

  function transferLicence(address from, address to) costs(transferFee) {
    if (licences[from] <= 0) throw;
    licences[from]--;
    licences[to]++;

    LicenceTransfered(from, to, 1);
  }

  function revokeLicence(
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

  function checkLicence(address customer) returns (bool) {
    return licences[customer] > 0;
  }

  function registerDiscount(Discount discount) onlyOwner {
    discounts[discount] = true;

    DiscountAdded(discount);
  }

  function unregisterDiscount(Discount discount) onlyOwner {
    discounts[discount] = false;

    DiscountRemoved(discount);
  }

  function kill() onlyOwner {
    selfdestruct(owner);
  }

  function applyDiscount(
    address discountAddress,
    uint total,
    LicenceRequest[] requests
  )
    internal returns (uint) {
    if (!discounts[discount]) {
      return total;
    }
    Discount discount = Discount(discountAddress);
    return discount.apply(total, requests);
  }

  function priceMult(uint x) internal returns (uint) {
    return price * x;
  }
}
