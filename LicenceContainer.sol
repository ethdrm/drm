pragma solidity ^0.4.9;

contract LicenceContainer {

  mapping(address => uint) private licences;

  function add(address to, uint amount) returns (bool) {
    if (licences[to] + amount < licences[to]) {
      return false;
    }
    licences[to] += amount;
    return true;
  }

  function revoke(address from, uint amount) returns (bool) {
    if (licences[from] < amount) {
      return false;
    }
    licences[from] -= amount;
  }

  function transfer(address from, address to, uint amount) returns (bool) {
    if (licences[from] < amount || licences[to] + amount < licences[to]) {
      return false;
    }
    licences[from] -= amount;
    licences[to] += amount;
    return true;
  }

  function owns(address owner, uint amount) returns (bool) {
    return licences[owner] >= amount;
  }
}
