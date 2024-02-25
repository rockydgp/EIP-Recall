var VaultFactory = artifacts.require("VaultFactory");
var TokenFactory = artifacts.require("TokenFactory");
var RWA = artifacts.require("MyRWA");
var AnonAadhaar = artifacts.require("AnonAadhaarVerifier");

module.exports = function(deployer) {
  // deployment steps
  deployer.deploy(RWA);
  deployer.deploy(AnonAadhaar);
  deployer.deploy(TokenFactory)
  // rwa = RWA.deployed();
  anon = AnonAadhaar.deployed();
  deployer.deploy(VaultFactory, anon.getAddress());
  };
