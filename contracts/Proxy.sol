pragma solidity ^0.4.8;

import "./ProxyStorage.sol";

contract Proxy {

    function() payable {
        // warning: should change this value during deployment
        ProxyStorage proxyStorage = ProxyStorage(0x1111222233334444555566667777888899990000);
        uint32 len = proxyStorage.sizes(msg.sig);
        address target = proxyStorage.target();
        
        assembly {
            calldatacopy(0x0, 0x0, calldatasize)
            let o_code := mload(0x40)
            let retval := delegatecall(sub(gas, 10000), target, 0x0, calldatasize, o_code, len)
            // if retval == 0 then contract threw exception
            jumpi(0x02, iszero(retval))

            return(o_code, len)
        }
    }
}