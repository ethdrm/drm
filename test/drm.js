var Drm = artifacts.require("./Drm.sol");

contract('Drm', function(accounts) {
	it("should set price and transfer fee", function() {
		var drm;
		var price = 100;
		var fee = 30;

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

	it("should register a licence", function() {
		var drm;

		var amount = 42;
		var price = 100;
		var fee = 30;

		return Drm.new(price, fee).then(function(instance) {
			drm = instance;
		}).then(function() {
			return drm.buy([accounts[0],], [amount,], [], {from: accounts[0], value: price * amount});
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'LicenceBought', "Event wasn't fired");
			assert.equal(txInfo.logs[0].args.to[0], accounts[0], "Licence holder is invalid");
			assert.equal(txInfo.logs[0].args.amount[0], amount, "Licence amount is invalid");
		});
	});

	it("should revoke licence", function() {
		// TODO: move to before test
		var drm;

		var amount = 42;
		var price = 100;
		var fee = 30;
		var reason = 'no reason';

		return Drm.new(price, fee, {from: accounts[1]}).then(function(instance) {
			drm = instance;
		}).then(function() {
			drm.buy([accounts[0],], [amount,], [], {from: accounts[0], value: price * amount});
		}).then(function() {
			return drm.revoke(accounts[0], amount, reason, {from: accounts[1]});
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'LicenceRevoked', "Event wasn't fired");
			assert.equal(txInfo.logs[0].args.customer, accounts[0], "Revoked from the wrong holder");
			assert.equal(txInfo.logs[0].args.amount, amount, "Revoked wrong amount");
			assert.equal(txInfo.logs[0].args.reason, reason, "Different revoke reason")
		});
	});

	it("should transfer licence", function() {
		var drm;

		var price = 100;
		var transferFee = 30;

		var from = accounts[0];
		var to = accounts[1];
		var transferAmount = 42;

		var fromStartAmount = 1437;
		var toStartAmount = 1337;

		return Drm.new(price, transferFee).then(function(instance) {
			drm = instance;
		}).then(function() {
			var customers = [from, to];
			var amount = [fromStartAmount, toStartAmount];
			var discounts = []
			drm.buy(customers, amount, discounts, {from: accounts[2], value: price * (fromStartAmount + toStartAmount)});
		}).then(function() {
			return drm.transfer(to, transferAmount, {from: from, value: transferAmount * transferFee});
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'LicenceTransfered', "Event wasn't fired");
			assert.equal(txInfo.logs[0].args.from, from, 'Licence transfer from wrong account');
			assert.equal(txInfo.logs[0].args.to, to, 'Licence transfered to wrong account');
			assert.equal(txInfo.logs[0].args.amount, transferAmount, 'Transfered wrong amount');
		});
	});

	it("should check for licence", function() {
		var drm;

		var price = 100;
		var fee = 30;

		var customer = accounts[0];
		var someAddr = accounts[1];
		var amount = 1337;

		return Drm.new(price, fee).then(function(instance) {
			drm = instance;
		}).then(function() {
			drm.buy([customer], [amount], [], {value: price * amount});
		}).then(function() {
			return drm.check(customer, amount);
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'HasLicence', "Event wasn't fired");
			assert.equal(txInfo.logs[0].args.customer, customer, "Wrong customer check");
			assert.equal(txInfo.logs[0].args.amount, amount, "Wrong amount check");
			assert.equal(txInfo.logs[0].args.status, true, "Check status is invalid");

			return drm.check(customer, amount + 1);
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'HasLicence', "Event wasn't fired");
			assert.equal(txInfo.logs[0].args.status, false, "Check status is invalid");

			return drm.check(someAddr, 1);
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'HasLicence', "Event wasn't fired");
			assert.equal(txInfo.logs[0].args.status, false, "Check status is invalid");
		});
	});

	it("should ban customer", function() {
		var drm;

		var price = 100;
		var fee = 30;

		var customer = accounts[0];
		var reason = 'no reason';

		return Drm.new(price, fee).then(function(instance) {
			drm = instance;
		}).then(function() {
			return drm.ban(customer, reason);
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'CustomerBanned', "Event wasn't fired");
			assert.equal(txInfo.logs[0].args.customer, customer, "Banned wrong customer");
			assert.equal(txInfo.logs[0].args.reason, reason, "invalid reason specified");
		});
	});

	it("should change price", function() {
		var drm;

		var price = 100;
		var fee = 30;
		var owner = accounts[1];

		var newPrice = 1437;

		return Drm.new(price, fee, {from: owner}).then(function(instance) {
			drm = instance;
		}).then(function() {
			return drm.changePrice(newPrice, {from: owner});
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'PriceChanged', "Event wasn't fired");
			assert.equal(txInfo.logs[0].args.oldPrice, price, "Old price is invalid");
			assert.equal(txInfo.logs[0].args.newPrice, newPrice, "New price is invalid");
		});
	});

	it("should change transfer fee", function() {
		var drm;

		var price = 100;
		var fee = 30;
		var owner = accounts[1];

		var newFee = 42;

		return Drm.new(price, fee, {from: owner}).then(function(instance) {
			drm = instance;
		}).then(function() {
			return drm.changeTransferFee(newFee, {from: owner});
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'TransferFeeChanged', "Event wasn't fired");
			assert.equal(txInfo.logs[0].args.oldFee, fee, "Old fee is invalid");
			assert.equal(txInfo.logs[0].args.newFee, newFee, "New fee is invalid");
		});
	});

	it("should register discount", function() {
		var price = 100;
		var fee = 30;
		var owner = accounts[1];

		var discount = 0x0;
		var description = "test discount";

		return Drm.new(price, fee, {from: owner}).then(function(instance) {
			return instance.registerDiscount(discount, description, {from: owner});
		}).then(function(txInfo) {
				assert.equal(txInfo.logs[0].event, 'DiscountAdded', "Event wasn't fired");
				assert.equal(txInfo.logs[0].args.description, description, "Description is invalid");
		});
	});

	it("should deregister discount", function() {
		var price = 100;
		var fee = 30;
		var owner = accounts[1];

		var discount = 0x0;

		return Drm.new(price, fee, {from: owner}).then(function(instance) {
			return instance.deregisterDiscount(discount, {from: owner});
		}).then(function(txInfo) {
			assert.equal(txInfo.logs[0].event, 'DiscountRemoved', "Event wasn't fired");
		});
	});
});