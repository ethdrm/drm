pragma solidity ^0.4.5;

import "truffle/Assert.sol";
import "../contracts/LicenceContainer.sol";
import "../contracts/Discount.sol";

contract TestLicenceContainer {

	function testAdding() {
		LicenceContainer container = new LicenceContainer();

		container.add(tx.origin, 42);

		Assert.isTrue(container.owns(tx.origin, 42), "Address owns at least 42 licences");
		Assert.isFalse(container.owns(tx.origin, 43), "Address owns less then 43 licences");
	}

	function testAddingOverflow() {
		LicenceContainer container = new LicenceContainer();

		Assert.isFalse(container.owns(tx.origin, 1), "Address has no licences");


		Assert.isTrue(container.add(tx.origin, uint(-1)), "Adding max uint");

		Assert.isFalse(container.add(tx.origin, 42), "Overflow error");

	  Assert.isTrue(container.owns(tx.origin, uint(-1)), "Overflow error was handled");
	}

	function testRevoke() {
		LicenceContainer container = new LicenceContainer();

		container.add(tx.origin, 42);
		Assert.isTrue(container.owns(tx.origin, 42), "Address has at least 42 licences");
		Assert.isFalse(container.owns(tx.origin, 43), "Address has less then 43 licences");

		Assert.isTrue(container.revoke(tx.origin, 42), "Revoked 42 licences");
		Assert.isFalse(container.owns(tx.origin, 1), "Address has no licences");
	}

	function testTransfer() {
		LicenceContainer container = new LicenceContainer();

		container.add(tx.origin, 42);

		Assert.isTrue(container.transfer(tx.origin, 0x12345, 42), "Transfered licences");

		Assert.isFalse(container.owns(tx.origin, 1), "Sender has no licences");
		Assert.isTrue(container.owns(0x12345, 42), "Transfer success");
	}

	function testTransferOverflow() {
		LicenceContainer container = new LicenceContainer();

		Assert.isTrue(container.add(tx.origin, uint(-1)), "Added max to sender");
		Assert.isTrue(container.add(0x12345, 42), "Added 42 to receiver address");

		Assert.isFalse(container.transfer(tx.origin, 0x12345, uint(-1)), "Overflow");

		Assert.isTrue(container.owns(tx.origin, uint(-1)), "Sender has the same amount");
		Assert.isTrue(container.owns(0x12345, 42), "Receiver has the same amount");
	}
}
