pragma solidity ^0.4.8;

import "./Mortal.sol";

contract LicenseDomain is Mortal {
    address[] public clients;
    address public manager;

    event LicenseValidated(address client);

    function LicenseDomain(address[] _clients, address _manager) {
        clients = _clients;
        manager = _manager;
    }

    function add(address client) onlyOwner {
        clients.push(client);
    }

    function remove(address client) {
        for (uint i = 0; i < clients.length; i++) {
            if (clients[i] == client) {
                clients[i] = clients[clients.length - 1];
                delete clients[clients.length - 1];
                clients.length--;
                break;
            }
        }

        if (clients.length == 0) kill();
    }

    function clientsAmount() returns (uint) {
        return clients.length;
    }

    function validate() {
        for (uint i = 0; i < clients.length; i++) {
            if (clients[i] == msg.sender) {
                LicenseValidated(msg.sender);
                return;
            }
        }
    }
}