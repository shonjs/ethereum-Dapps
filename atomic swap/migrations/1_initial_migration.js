var interface = artifacts.require("IEthSwap");

module.exports = function(deployer) {
  // Deploy the Migrations contract as our only task
  deployer.deploy(interface);
};