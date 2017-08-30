const ZiomiToken = artifacts.require('./ZiomiToken.sol');
const address = '0x1440cbef11f6055efd8597d8398e2ddf6d9c40b7';

contract('ZiomiToken', function (accounts) {
  it('getOwner', function () {
    return ZiomiToken.deployed()
      .then((instance) => instance.getOwner.call())
      .then((owner) => assert.equal(owner, address, 'getOwner returns ' + owner));
  });

  it('getLocked', function () {
    return ZiomiToken.deployed()
      .then((instance) => instance.getLocked.call())
      .then((locked) => assert.equal(locked, true, 'getLocked returns ' + locked));
  });

  it('create tokens', function () {
    return ZiomiToken.deployed()
      .then((instance) => instance.create(address, 132, {from: address}))
      .then((result) => {
        assert.equal(Boolean(result && result.tx), true, 'empty transaction hash');
        assert.equal(Array.from(result.logs).some((log) => log.event === 'Create'), true, 'Create is not emitted');
      })
      .then(() => ZiomiToken.deployed())
      .then((instance) => instance.balanceOf.call(address))
      .then((balance) => assert.equal(balance.valueOf(), '132', 'balanceOf'));
  });

  it('unlock contract', function () {
    let ziomiTokenInstance;
    return ZiomiToken.deployed()
      .then((instance) => {
        ziomiTokenInstance = instance;
        return instance.unlock({from: address});
      })
      .then((result) => {
        assert.equal(Boolean(result && result.tx), true, 'empty transaction hash');
        assert.equal(Array.from(result.logs).some((log) => log.event === 'Unlock'), true, 'Unlock is not emitted');
      })
      // test getLocked
      .then(() => ziomiTokenInstance.getLocked.call())
      .then((locked) => assert.equal(locked, false, 'getLocked returns ' + locked))
      // test create
      .then(() => ziomiTokenInstance.create(address, 1, {from: address}))
      .then((result) => assert.equal(Boolean(result && result.tx), false, 'Token created'))
      .catch((error) => console.log(assert.equal(Boolean(error), true), error.message));
  });

});
