pragma solidity ^0.4.8;

contract DrmInterface {
    function price() returns(uint);
    function transferFee() returns(uint);
    function licenses(address client) returns(address);
    function purchase(address[] clients, address[] discounts) payable;
    function transfer(address[] from, address[] to, address manager, address[] discounts) payable;
    function discountRegistry() returns(address);
}