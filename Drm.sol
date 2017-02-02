pragma solidity ^0.4.5;

import "ArrayUtils.sol";
import "FunctionUtils.sol";


contract Drm {
  using ArrayUtils for *;

  mapping(address => uint) public licences;
  mapping(address => bool) public blacklist;

  address public owner;
  uint public price;
  uint transferFee;

  event LicenceBought(address customer, uint amount);
  event LicenceTransfered(address from, address to, uint amount);
  event LicenceRevoked(address customer, uint amount, string reason);

  event CustomerBanned(address customer, string reason);

  event PriceChanged(uint oldPrice, uint newPrice);
  event TransferFeeChanged(uint oldPrice, uint newPrice);

  event DepositeReceived(address sender, uint amount);

  modifier onlyOwner() {
    if (msg.sender != owner) throw;
    _;
  }

  modifier costs(uint amount) {
    if (msg.value < amount) throw;
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

  function buyLicence() payable notBlacklisted costs(price) {
    licences[msg.sender] += 1;

    LicenceBought(msg.sender, 1);
  }

  //TODO: check for overflow
  function buyLicences(address[] customers, uint[] amount) payable {
    if (customers.length != amount.length) throw;
    if (msg.value < amount.map(priceMult).reduce(FunctionUtils.sum)) throw;

    for (uint i = 0; i < customers.length; i++) {
      if (blacklist[customers[i]]) throw;
      licences[customers[i]] += amount[i];
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

  function kill() onlyOwner {
    selfdestruct(owner);
  }

  function priceMult(uint x) internal returns (uint) {
    return price * x;
  }
}