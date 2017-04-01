var Drm = artifacts.require("./Drm.sol");

contract('Drm', function(accounts) {
    var drm;
    var price = 100;
    var fee = 30;
    
	it("should set price and transfer fee", function() {
		var deployedPrice;
		var deployedFee;

		return Drm.new(price, fee).then(function(instance) {
			drm = instance;
			return drm.price();
		}).then(function(p) {
			deployedPrice = p.toNumber();
			return drm.transferFee();
		}).then(function(f) {
			deployedFee = f.toNumber();

			assert.equal(deployedFee, fee, "Fee was't deployed correctly");
			assert.equal(deployedPrice, price, "Price wasn't deployed correctly");
		});
	});

    it("should register license", function() {
        var client = accounts[4];
        var manager = accounts[0];

        return Drm.new(price, fee).then(function(instance) {
            drm = instance;
        }).then(function() {
            return drm.purchase([client], [], {from: manager, value: price})
        }).then(function(txInfo) {
            assert.equal(txInfo.logs[0].event, 'LicensePurchase', "Event wasn't fired");
            assert.equal(txInfo.logs[0].args.client, manager, "Event was fired for the wrong client");
        });
    });

    it("should reister license in existing domain", function() {
        var domain;

        var client = accounts[0];
        var addedAccount = accounts[1];

        return Drm.new(price, fee).then(function(instance) {
            drm = instance;
        }).then(function() {
            return drm.purchase([client], [], {from: client, value: price});
        }).then(function(txInfo) {
            assert.equal(txInfo.logs[0].event, 'LicensePurchase', "Initial purchase failed");
            domain = txInfo.logs[0].args.domain;
        }).then(function() {
            return drm.purchase([addedAccount], [], {from: client, value: price});
        }).then(function(txInfo) {
            assert.equal(txInfo.logs[0].event, 'LicensePurchase', "Additional purchase failed");
            assert.equal(txInfo.logs[0].args.domain, domain, "Additional purchase was registered for the wrong domain");
        });
    });

    it("should register multiple clients", function() {
        var clients = accounts;
        var manager = clients[0];

        return Drm.new(price, fee).then(function(instance) {
            drm = instance;
        }).then(function() {
            return drm.purchase(clients, [], {from: manager, value: price * accounts.length});
        }).then(function(txInfo) {
            assert.equal(txInfo.logs[0].event, 'LicensePurchase', "Event for multiple clients wasn't fired");
            assert.equal(txInfo.logs[0].args.client, manager);
        });
    });

    it ("should revoke license from regular client", function() {
        var client = accounts[3];
        var manager = accounts[0];
        var drmOwner = accounts[accounts.length - 1];

        return Drm.new(price, fee, {from: drmOwner}).then(function(instance) {
            drm = instance;
        }).then(function() {
            return drm.purchase([client], [], {from: manager, value: price});
        }).then(function(txInfo) {
            assert.equal(txInfo.logs[0].event, 'LicensePurchase', "Purchase event wasn't fired");
            assert.equal(txInfo.logs[0].args.client, manager, "Domain was registered for the wrong address");
        }).then(function() {
            return drm.revoke(client, {from: drmOwner});
        }).then(function(txInfo) {
            assert.equal(txInfo.logs[0].event, 'LicenseRevoke', "License revoke event wasn't fired");
            assert.equal(txInfo.logs[0].args.from, client, "License was revoked from the wrong client");
        });
    });

	it ("should revoke all licenses in domain", function() {
		var client = accounts[0];
		var manager = accounts[1];
		var clients = [client, manager];
		var drmOwner = accounts[2];

		return Drm.new(price, fee, {from: drmOwner}).then(function(instance) {
			drm = instance;
		}).then(function() {
			return drm.purchase(clients, [], {from: manager, value: clients.length * price});
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'LicensePurchase', "License purchase event wasn't fired");
		}).then(function() {
			return drm.revoke(manager, {from: drmOwner});
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'LicenseRevoke', "Domain licenses weren't revoked");
		});
	});

	it("should transfer license", function() {
		var from = accounts[0];
		var to = accounts[1];
		var manager = accounts[2];
		var toManager = accounts[3];
		var drmOwner = accounts[4];

		return Drm.new(price, fee, {from: drmOwner}).then(function(instance) {
			drm = instance;
		}).then(function() {
			return drm.purchase([from], [], {from: manager, value: price});	
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'LicensePurchase', "License purchase event wasn't fired");
		}).then(function() {
			return drm.transfer([from], [to], toManager, [], {from: manager, value: fee});
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'LicenseTransfer', "License transfer event wasn't fired");
			assert.equal(txInfo.logs[0].args.from, manager, "License transfer from is invalid");
			assert.equal(txInfo.logs[0].args.to, toManager, "License transfer to is invalid");
		});
	});

	it("should transfer license to existing domain", function() {
		var fromManager = accounts[0];
		var toManager = accounts[1];
		var to = accounts[2];
		var drmOwner = accounts[3];
		var toDomain;

		return Drm.new(price, fee, {from: drmOwner}).then(function(instance) {
			drm = instance;
		}).then(function() {
			return drm.purchase([fromManager], [], {from: fromManager, value: price});
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'LicensePurchase', "LicensePurchase event wasn't fired");
		}).then(function() {
			return drm.purchase([toManager], [], {from: toManager, value: price});
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'LicensePurchase', "LicensePurchase event wasn't fired");
			toDomain = txInfo.logs[0].args.domain;
		}).then(function() {
			return drm.transfer([fromManager], [to], toManager, [], {from: fromManager, value: fee});
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'LicenseTransfer', "LicenseTransfer event wasn't fired");
			assert.equal(txInfo.logs[0].args.from, fromManager, "LicenseTransfer#from is invalid");
			assert.equal(txInfo.logs[0].args.to, toManager, "LicenseTransfere#to is invalid");
			assert.equal(txInfo.logs[0].args.toDomain, toDomain, "LicenseTransfer#domain is invalid");
		});
	});

	it("should ban client", function() {
		var drmOwner = accounts[5];
		var client = accounts[1];

		return Drm.new(price, fee, {from: drmOwner}).then(function(instance) {
			drm = instance;
		}).then(function() {
			return drm.ban(client, {from: drmOwner});
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'ClientBan', "Client ban event wasn't fired");
			assert.equal(txInfo.logs[0].args.client, client, "Banned wrong client");
		});
	});

	it("should unban client", function() {
		var drmOwner = accounts[4];
		var client = accounts[0];

		return Drm.new(price, fee, {from: drmOwner}).then(function(instance) {
			drm = instance;
		}).then(function() {
			return drm.unban(client, {from: drmOwner});
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'ClientUnban', "Client unban event wasn't fired");
			assert.equal(txInfo.logs[0].args.client, client, "Unbanned wrong client");
		});
	});

	it("should change price", function() {
		var expected = 100500;
		var drmOwner = accounts[accounts.length - 1];
		
		return Drm.new(price, fee, {from: drmOwner}).then(function(instance) {
			drm = instance;
		}).then(function() {
			drm.changePrice(expected, {from: drmOwner});
		}).then(function() {
			return drm.price();
		}).then(function(actual) {
			assert.equal(expected, actual, "Price wasn't set");
		});
	});

	it("should change fee", function() {
		var expected = 100500;
		var drmOwner = accounts[accounts.length - 1];
		
		return Drm.new(price, fee, {from: drmOwner}).then(function(instance) {
			drm = instance;
		}).then(function() {
			drm.changeTransferFee(expected, {from: drmOwner});
		}).then(function() {
			return drm.transferFee();
		}).then(function(actual) {
			assert.equal(expected, actual, "Price wasn't set");
		});
	});
});
