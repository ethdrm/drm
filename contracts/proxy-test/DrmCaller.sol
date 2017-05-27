pragma solidity ^0.4.8;

import './DrmInterface.sol';

contract DrmCaller {
    DrmInterface public target;
    address[] clients;
    address[] from;
    address[] to;
    address[] discounts;

    function DrmCaller(DrmInterface _target) {
        target = _target;
    }

    function price() returns(uint) {
        return target.price();
    }

    function transferFee() returns(uint) {
        return target.transferFee();
    }

    function purchase(address client) payable {
        clients.push(client);
        target.purchase.value(msg.value)(clients, discounts);
    }

    function transfer(address client, address other) payable {
        from.push(client);
        to.push(other);
        target.transfer.value(msg.value)(from, to, other, discounts);
    }

    function licenses(address client) returns(address) {
        return target.licenses(client);
    }

    function discountRegistry() returns(address) {
        return target.discountRegistry();
    }
}