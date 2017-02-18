pragma solidity ^0.4.8;

import "./Discount.sol";
import "./DiscountRegistry.sol";
import "./LicenceContainer.sol";
import "./Mortal.sol";


contract Drm is Mortal {

  mapping(address => bool) public blacklist;

  LicenceContainer licenceContainer;
  DiscountRegistry discountRegistry;
  uint public price;
  uint public transferFee;

  event LicenceBought(address[] to, uint[] amount);
  event LicenceTransfered(address from, address to, uint amount);
  event LicenceRevoked(address customer, uint amount, string reason);

  event DiscountAdded(address discount);
  event DiscountRemoved(address discount);

  event CustomerBanned(address customer, string reason);

  event PriceChanged(uint oldPrice, uint newPrice);
  event TransferFeeChanged(uint oldFee, uint newFee);

  event DepositeReceived(address sender, uint amount);

	event HasLicence(address customer, uint amount, bool status);

  modifier onlyOwner() {
    if (msg.sender != owner) throw;
    _;
  }

  modifier costs(uint cost) {
    if (msg.value < cost) throw;
    _;
  }

  function Drm(uint startPrice, uint startTransferFee) {
    price = startPrice;
    transferFee = startTransferFee;
		licenceContainer = new LicenceContainer();
		discountRegistry = new DiscountRegistry();
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
    for (uint i = 0; i < amount.length; i++) {
      if (blacklist[to[i]]) throw;
      total += amount[i] * price;
    }

    for (i = 0; i < discounts.length; i++) {
      var (discount, error) = discountRegistry.get(discounts[i]);
      if (!error) {
        total = discount.apply(total, to, amount);
      }
    }
    if (msg.value < total) throw;

    for (i = 0; i < to.length; i++) {
      if (!licenceContainer.add(to[i], amount[i])) throw;
    }

    LicenceBought(to, amount);
  }

  function transfer(
    address to,
    uint amount
  ) payable costs(transferFee * amount) {
    if (blacklist[to]) throw;
    if (!licenceContainer.transfer(msg.sender, to, amount)) throw;

    LicenceTransfered(msg.sender, to, amount);
  }

  function revoke(
    address from,
    uint amount,
		string reason
  ) onlyOwner {
    if (!licenceContainer.revoke(from, amount)) throw;

    LicenceRevoked(from, amount, reason);
  }

  function check(address customer, uint amount) returns (bool) {
		bool status = licenceContainer.owns(customer, amount);
		
		HasLicence(customer, amount, status);
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
}
