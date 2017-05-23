pragma solidity ^0.4.8;

import './ProxyStorage.sol';
import './Drm.sol';

contract DrmManagement {
    ProxyStorage public proxyStorage;

    function DrmManagement(ProxyStorage _proxyStorage) {
        proxyStorage = _proxyStorage;
    }

    function deployDrm(address target, Drm proxy, uint price, uint transferFee) {
        proxyStorage.migrate(target);
        proxy.setOwner(this);
        proxy.setPrice(price);
        proxy.setTransferFee(transferFee);
    }
}