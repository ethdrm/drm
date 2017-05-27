var Proxy = artifacts.require("./Proxy.sol");
var ProxyStorage = artifacts.require("./ProxyStorage.sol");
var Drm = artifacts.require("./Drm.sol");
var DrmCaller = artifacts.require("./DrmCaller.sol");
var DrmManagement = artifacts.require("./DrmManagement.sol");
var Web3 = require('web3');

contract('Proxy', function(accounts) {
    var caller;
    var price = 70;
    var transferFee = 30;
    var client = accounts[accounts.length - 1];

    it("should return drm initial params", function() {
        return init(price, transferFee).then(function(instance) {
            caller = instance;
            return caller.price.call();
        }).then(function(actual) {
            assert.equal(actual.toNumber(), price);
            return caller.transferFee.call();
        }).then(function(actual) {
            assert.equal(actual.toNumber(), transferFee);
            return caller.discountRegistry.call();
        }).then(function(registry) {
            assert.notEqual(registry, 0x0);
        });
    });

    it("should purchase license", function() { 
        return init(price, transferFee).then(function(instance) {
            caller = instance;
            return caller.purchase(client, {value: price});
        }).then(function() {
            return caller.licenses.call(client);
        }).then(function(actual) {
            assert.notEqual(actual, 0x0);
        });
    });

    it("should transfer license", function() {
        var client = accounts[0];
        var other = accounts[1];

        return init(price, transferFee).then(function(instance) {
            caller = instance;
            return caller.purchase(client, {value: price, from: client});
        }).then(function() {
            return caller.transfer(client, other, {value: transferFee, from: client});
        }).then(function() {
            return caller.licenses.call(client);
        }).then(function(actual) {
            assert.equal(actual, 0x0);
            return caller.licenses.call(other);
        }).then(function(actual) {
            assert.notEqual(actual, 0x0);
        });
    });
});

function init(price, transferFee) {

    var drm;
    var management;
    var proxyStorage;
    var proxy;
    var web3 = new Web3();

    return Drm.new().then(function(instance) {
        drm = instance;
        return ProxyStorage.new();
    }).then(function(instance) {
        proxyStorage = instance;
        funcs = drm.abi.filter(obj => obj.type === 'function');
        funcs.map(fn => proxyStorage.registerSize(web3.sha3(signature(fn)), size(fn))).reduce((prev, cur) => prev.then(cur), Promise.resolve());
    }).then(function() {
        return DrmManagement.new(proxyStorage.address);
    }).then(function(instance) {
        management = instance;
        return proxyStorage.setOwner(management.address);
    }).then(function() {
        Proxy.unlinked_binary = Proxy.unlinked_binary.replace('1111222233334444555566667777888899990000', proxyStorage.address.slice(2));
        Proxy.unlinked_binary = Proxy.unlinked_binary.replace('1111222233334444555566667777888899990001', management.address.slice(2));
        return Proxy.new();
    }).then(function(instance) {
        proxy = instance;
        Proxy.unlinked_binary = Proxy.unlinked_binary.replace(proxyStorage.address.slice(2), '1111222233334444555566667777888899990000');
        Proxy.unlinked_binary = Proxy.unlinked_binary.replace(management.address.slice(2), '1111222233334444555566667777888899990001');
        return management.deployDrm(drm.address, proxy.address, price, transferFee);
    }).then(function() {
        return DrmCaller.new(proxy.address);
    });
}

function signature(fn) {
    var name = fn.name + "(" + fn.inputs.map(input => input.type).join(",") + ")";
    console.log(name);
    return name;
}

function size(fn) {
    if (!fn.constant) {
        return 0;
    }
    var sizes = {
        "uint256": 256,
        // TODO
        "bool": 1,
        "address": 256,
        "uint": 256,
        "uint32": 32
    };
    var outType = fn.outputs[0].type;
    if (outType in sizes) {
        console.log("constructed size", sizes[outType]);
        return sizes[outType];
    } else {
        return 0;
    }
}