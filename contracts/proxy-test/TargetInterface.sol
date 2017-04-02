pragma solidity ^0.4.8;

contract TargetInterface {
    function setNumber(uint number);
    function getNumber() payable returns(uint);
}