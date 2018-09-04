var Token = artifacts.require("./HelloNetTrustScore.sol");
var TokenLockContract = artifacts.require("./TokenTimelock");


module.exports = function(deployer, network, accounts) {
  deployer.deploy(Token).then(function(){
    return deployer.deploy(TokenLockContract,Token.address,accounts[0],20000000,1535615466);
  })
};
