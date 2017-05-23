pragma solidity ^0.4.8;

import "./Discount.sol";
import "./DiscountRegistry.sol";
import "./LicenseDomain.sol";
import "./Mortal.sol";


contract Drm is Mortal {
    uint public price;
    uint public transferFee;

    DiscountRegistry public discountRegistry = new DiscountRegistry();    
    
    mapping(address => bool) public blacklist;
    mapping(address => LicenseDomain) public domains;
    mapping(address => LicenseDomain) public licenses;
    
    event LicensePurchase(address client, address domain);
    event LicenseTransfer(address from, address to, address toDomain, uint amount);
    event LicenseRevoke(address from, address domain);
    
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

    function Drm() {
        // warning: never set values in constructor, they won't be visible 
        // in proxy (cause it executes delegatecall and we're using proxy context)
    }

    function setPrice(uint _price) onlyOwner {
        price = _price;
    }

    function setTransferFee(uint _transferFee) onlyOwner {
        transferFee = _transferFee;
    }
    
    function purchase(address[] clients, address[] discounts) payable notBanned(tx.origin) {
        uint total = applyDiscounts(clients.length * price, clients.length, Discount.ClientAction.PURCHASE, discounts);
        if (msg.value < total) throw;
        
        LicenseDomain domain = domains[tx.origin];
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
            for (uint i = 0; i < domain.clientsAmount(); i++) {
                licenses[domain.clients(i)] = LicenseDomain(0x0);
            }
            domain.kill();
            domains[client] = LicenseDomain(0x0);
        } else {
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

    function() {}
}