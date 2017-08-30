var ZiomiToken = artifacts.require('./ZiomiToken.sol');
var ZiomiPresale = artifacts.require('./ZiomiPresale.sol');

module.exports = (deployer, network, accounts) => {
  deployer.deploy(ZiomiToken).then(() => {
    const startTime = new Date('29 Aug 2017 GMT+0') / 1000;
    const endTime = new Date('10 Sep 2017 GMT+0') / 1000;

    return deployer.deploy(ZiomiPresale, ZiomiToken.address, startTime, endTime);
  });
};
