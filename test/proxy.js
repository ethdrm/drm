var Proxy = artifacts.require("./Proxy.sol");
var ProxyStorage = artifacts.require("./ProxyStorage.sol");
var Target = artifacts.require("./Target.sol");
var TargetCaller = artifacts.require("./TargetCaller.sol");
var Web3 = require('web3');

contract('Proxy', function(accounts) {
    var proxyStorage;
    var targetNumber = 1437;
    var callerNumber = 42;
    var web3 = new Web3();

    it ("should return target number", function() {
        return Target.new().then(function(target) {
            return ProxyStorage.new(target.address);
        }).then(function(instance) {
            proxyStorage = instance;
            // register function retsize
            var signature = web3.sha3("getNumber()");
            console.log(signature);
            proxyStorage.registerSize(signature, 32);
        }).then(function() {
            Proxy.unlinked_binary = Proxy.unlinked_binary.replace('1111222233334444555566667777888899990000', proxyStorage.address.slice(2));
            return Proxy.new();
        }).then(function(proxy) {
            return TargetCaller.new(proxy.address, callerNumber, targetNumber);
        }).then(function(caller) {
            return caller.extractNumber.call();
        }).then(function(number) {
            assert.equal(targetNumber, number.toNumber());
        });
    });
});