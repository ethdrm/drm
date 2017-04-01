var LicenseDomain = artifacts.require("./LicenseDomain.sol");

contract(LicenseDomain, function(accounts) {
    var domain;

    it("should validate license", function() {
        var client = accounts[0];
        var manager = accounts[1];
        var owner = accounts[2];

        return LicenseDomain.new([client, manager], manager, {from: owner}).then(function(instance) {
            domain = instance;
        }).then(function() {
            return domain.validate({from: client});
        }).then(function(txInfo) {
            assert.equal(txInfo.logs[0].event, 'LicenseValidated', "License validation event wasn't fired");
            assert.equal(txInfo.logs[0].args.client, client, "Event validation was fired for wrong client");
        });
    });
});