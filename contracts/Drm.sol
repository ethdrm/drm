pragma solidity ^0.4.8;

import "./Discount.sol";
import "./DiscountRegistry.sol";
import "./LicenseDomain.sol";
import "./Mortal.sol";


contract Drm is Mortal {

  mapping(address => bool) public blacklist;
  mapping(address => LicenseDomain) public domains;
  mapping(address => LicenseDomain) public licenses;

  DiscountRegistry public discountRegistry = new DiscountRegistry();

  uint public price;
  uint public transferFee;

  event LicensePurchase(address client, LicenseDomain domain);
  event LicenseTransfer(address from, address to, LicenseDomain toDomain, uint amount);
  event LicenseRevoke(address from, LicenseDomain domain);

  event ClientBan(address client);
  event ClientUnban(address client);

  event PriceChange(uint oldPrice, uint newPrice);
  event TransferFeeChange(uint oldFee, uint newFee);

  modifier notBanned(address client) {
    if (blacklist[client]) throw;
    _;
  }

  modifier onlyDomainManager(LicenseDomain domain) {
    if (domains[tx.origin] != domain) throw;
    _;
  }

  function Drm(uint _price, uint _transferFee) {
    price = _price;
    transferFee = _transferFee;
  }

  function() {}

  function applyDiscounts(uint total, uint amount, Discount.ClientAction action, address[] discounts)
      private constant returns (uint) {
    for (uint i = 0; i < discounts.length; i++) {
      var (discount, error) = discountRegistry.get(discounts[i]);
      if (!error) {
        total = discount.apply(total, amount, action);
      }
    }

    return total;
  }

  function purchase(address[] clients, address[] discounts) payable notBanned(tx.origin) {
    uint total = applyDiscounts(clients.length * price, clients.length, Discount.ClientAction.PURCHASE, discounts);
    if (msg.value < total) throw;

    LicenseDomain domain = domains[tx.origin];
    // TODO: mb move to map as discounts?
    bool hadDomain = domain != LicenseDomain(0x0);
    if (!hadDomain) {
      domain = new LicenseDomain(clients, tx.origin);
    }

    for (uint i = 0; i < clients.length; i++) {
      if (blacklist[clients[i]] || licenses[clients[i]] != LicenseDomain(0x0)) throw;
      if (hadDomain) {
        domain.add(clients[i]);
      }
      licenses[clients[i]] = domain;
    }

    if (!hadDomain) {
      domains[tx.origin] = domain;
    }

    LicensePurchase(tx.origin, domain);
  }

  function transfer(address[] from, address[] to, address manager, address[] discounts)
      payable notBanned(tx.origin) notBanned(manager) {
    if (from.length != to.length) throw;
    
    uint total = applyDiscounts(transferFee * from.length, from.length, Discount.ClientAction.TRANSFER, discounts);
    if (msg.value < total) throw;

    // TODO: add domain as discount param  
    LicenseDomain domain = domains[manager];
    bool hadDomain = domain != LicenseDomain(0x0);
    if (!hadDomain) {
      domain = new LicenseDomain(to, manager);
    }
    
    for (uint i = 0; i < to.length; i++) {
      if (blacklist[from[i]] || licenses[from[i]].manager() != tx.origin) throw;
      if (blacklist[to[i]] || licenses[to[i]] != LicenseDomain(0x0)) throw;
      licenses[from[i]].remove(from[i]);
      licenses[from[i]] = LicenseDomain(0x0);
      if (hadDomain) {
        domain.add(to[i]);
      }
      licenses[to[i]] = domain;
    }

    if (!hadDomain) {
      domains[manager] = domain;
    }

    LicenseTransfer(tx.origin, manager, domain, from.length);
  }

  function revoke(address client) onlyOwner {
    LicenseDomain domain = domains[client];
    bool isDomainManager = domain != LicenseDomain(0x0);
    if (isDomainManager) {
      // TODO: somehow store extracted clients
      for (uint i = 0; i < domain.size(); i++) {
        licenses[domain.clients(i)] = LicenseDomain(0x0);
      }
      domain.kill();
      domains[client] = LicenseDomain(0x0);
    } else {
      // TODO: will it fail on 0x0?
      licenses[client].remove(client);
      licenses[client] = LicenseDomain(0x0);
    }

    LicenseRevoke(client, domain);
  }

  function ban(address client) onlyOwner {
    blacklist[client] = true;

    ClientBan(client);
  }

  function unban(address client) onlyOwner {
    blacklist[client] = false;
    
    ClientUnban(client);
  }

  function changePrice(uint newPrice) onlyOwner {
    uint oldPrice = price;
    price = newPrice;

    PriceChange(oldPrice, newPrice);
  }

  function changeTransferFee(uint newTransferFee) onlyOwner {
    uint oldTransferFee = transferFee;
    transferFee = newTransferFee;

    TransferFeeChange(oldTransferFee, newTransferFee);
  }
}