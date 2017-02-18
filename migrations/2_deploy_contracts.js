var LicenceContainer = artifacts.require("./LicenceContainer.sol");
var Mortal = artifacts.require("./Mortal.sol");
var Discount = artifacts.require("./Discount.sol");
var DiscountRegistry = artifacts.require("./DiscountRegistry.sol");
var Drm = artifacts.require("./Drm.sol");

module.exports = function(deployer) {
	deployer.deploy(DiscountRegistry);	
  deployer.deploy(LicenceContainer);
	deployer.deploy(Mortal);

	deployer.link(DiscountRegistry, Drm);
	deployer.link(Mortal, Drm);
	deployer.link(LicenceContainer, Drm);

	deployer.deploy(Drm);
};
