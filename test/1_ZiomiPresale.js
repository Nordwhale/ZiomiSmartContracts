const ZiomiPresale = artifacts.require('./ZiomiPresale.sol');
const ZiomiToken = artifacts.require('./ZiomiToken.sol');
const address = '0x1440cbef11f6055efd8597d8398e2ddf6d9c40b7';

contract('ZiomiPresale', (accounts) => {
  it('getOwner', function () {
    return ZiomiPresale.deployed()
      .then((instance) => instance.getOwner.call())
      .then((owner) => assert.equal(owner, address));
  });

  it('ZiomiToken.getOwner', function () {
    return ZiomiToken.deployed()
      .then((instance) => instance.getOwner.call())
      .then((owner) => assert.equal(owner, address));
  });

  it('getTokenAmount', function () {
    return ZiomiPresale.deployed()
      .then((instance) => instance.getTokenAmount.call(web3.toWei(6, 'ether')))
      .then((amount) => assert.equal(amount, 1200));
  });

  it('checkPresaleTokenAmount', function () {
    return ZiomiPresale.deployed()
      .then((instance) => instance.checkPresaleTokenAmount.call(1200))
      .then((result) => assert.equal(result, true));
  });

  it('ZiomiToken.getLocked', () => {
    return ZiomiToken.deployed()
      .then((instance) => instance.getLocked.call())
      .then((locked) => assert.equal(locked, true));
  });

  it('ZiomiToken.balanceOf', () => {
    return ZiomiToken.deployed()
      .then((instance) => instance.balanceOf.call(address))
      .then((balance) => assert.equal(balance.valueOf(), 0));

  });

  it('send 1 ether', function () {
    return ZiomiPresale.deployed()
      .then((instance) => instance.sendTransaction({from: address, value: web3.toWei(1, 'ether')}))
      .then((result) => assert.fail(result))
      .catch((error) => assert.ok(error));
  });

  it('send 6 ether', function () {
    return ZiomiPresale.deployed()
      .then((instance) => instance.sendTransaction({from: address, value: web3.toWei(6, 'ether')}))
      .then((result) => {
        assert.ok(result && result.tx, 'empty transaction hash');
        assert.ok(Array.from(result.logs).some((log) => log.event === 'Buy'), 'Buy is not emitted');
        return ZiomiToken.deployed();
      })
      .then((instance) => instance.balanceOf.call(address))
      .then((balance) => assert.equal(balance.valueOf(), 1200));
  });

});