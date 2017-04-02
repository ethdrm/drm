pragma solidity ^0.4.8;

import './TargetInterface.sol';

contract TargetCaller {
    TargetInterface public target;
    uint public number;

    event NumberExtracted(uint number);

    function TargetCaller(TargetInterface _target, uint _number, uint _targetNumber) {
        target = _target;
        number = _number;
        target.setNumber(_targetNumber);
    }

    function extractNumber() payable returns(uint) {
        return target.getNumber();
    }
}