pragma solidity ^0.4.8;

import './ProxyStorage.sol';
import './Drm.sol';
import './Mortal.sol';

contract DrmManagement is Mortal {
    ProxyStorage public proxyStorage;

    function DrmManagement(ProxyStorage _proxyStorage) {
        proxyStorage = _proxyStorage;
    }

    function deployDrm(address target, Drm proxy, uint price, uint transferFee) onlyOwner {
        proxyStorage.migrate(target);
        proxy.init(this);
        proxy.setPrice(price);
        proxy.setTransferFee(transferFee);
    }

    function migrate(address _management) onlyOwner {
        proxyStorage.setOwner(_management);
    }
}