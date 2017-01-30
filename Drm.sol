pragma solidity ^0.4.5;

import ArrayUtils for *;


contract Drm {
  mapping(address => uint) public licences;

  address public owner;
  uint public price;

  event LicenceBought(address customer, uint amount);
  event LicenceRevoked(address customer, uint amount, string reason);
  event DepositeReceived(address sender, uint amount);

  modifier onlyOwner() {
    if (msg.sender != owner) throw;
    _;
  }

  modifier costs(uint amount) {
    if (msg.value < amount) throw;
    _;
  }

  function Drm() {
    owner = msg.sender;
  }

  function() payable {
    DepositeReceived(msg.sender, msg.value);
  }

  function buyLicence() payable costs(price) {
    if (msg.value > price)
    licences[msg.sender] += 1;

    LicenceBought(msg.sender, 1);
  }

  //TODO: check for overflow
  function buyLicences(address[] customers, uint[] amount) payable {
    if (customers.length != amount.length) throw;
    if (msg.value < amount.map(mult).reduce(sum)) throw;

    for (uint i = 0; i < customers.length; i++) {
      licences[customers[i]] += amount;
    }
  }

  function revokeLicence(customer, amount, reason) onlyOwner {
    if (licences[customer] < amount) throw;
    licences[customer] -= amount;

    LicenceRevoked(customer, amount, reason);
  }

  function ban(address customer) onlyOwner {
    //TODO
  }



  function kill() onlyOwner {
    selfdestruct(owner);
  }
  //TODO: import from FunctionUtils
  function sum(uint x, uint y) internal returns(uint) {
    return x + y;
  }

  function mult(uint x) internal returns (uint) {
    return price * x;
  }
}
