pragma solidity ^0.4.5;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/DiscountRegistry.sol";
import "../contracts/Discount.sol";

contract TestDiscountRegistry {

	function testDiscountRegistration() {
		DiscountRegistry registry = new DiscountRegistry();

		address discountAddress = tx.origin;
		registry.register(tx.origin);

	  var (_, error) = registry.get(tx.origin);

		Assert.equal(error, false, "Discount was registered");
	}

	function testDiscountDeregistration() {
		DiscountRegistry registry = new DiscountRegistry();

		address discountAddress = tx.origin;
		registry.register(tx.origin);

		registry.deregister(tx.origin);

		var (_, error) = registry.get(tx.origin);

		Assert.equal(error, true, "Discount was deregestired");
	}
}
