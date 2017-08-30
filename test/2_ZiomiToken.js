const ZiomiToken = artifacts.require('./ZiomiToken.sol');
const address = '0x1440cbef11f6055efd8597d8398e2ddf6d9c40b7';

contract('ZiomiToken', (accounts) => {
  it('getOwner', function () {
    return ZiomiToken.deployed()
      .then((instance) => instance.getOwner.call())
      .then((owner) => assert.equal(owner, address, 'returns ' + owner));
  });

  it('getLocked', () => {
    return ZiomiToken.deployed()
      .then((instance) => instance.getLocked.call())
      .then((locked) => assert.equal(locked, true));
  });

  it('create tokens', () => {
    const amount = 132;

    return ZiomiToken.deployed()
      .then((instance) => instance.create(address, amount, {from: address}))
      .then((result) => {
        assert.ok(result && result.tx, 'empty transaction hash');
        assert.ok(Array.from(result.logs).some((log) => log.event === 'Create'), 'Create is not emitted');
      })
      .then(() => ZiomiToken.deployed())
      .then((instance) => instance.balanceOf.call(address))
      .then((balance) => assert.equal(balance.valueOf(), amount, 'balanceOf'));
  });

  it('unlock contract', () => {
    let ziomiTokenInstance;
    return ZiomiToken.deployed()
      .then((instance) => {
        ziomiTokenInstance = instance;
        return instance.unlock({from: address});
      })
      .then((result) => {
        assert.ok(result && result.tx, 'empty transaction hash');
        assert.ok(Array.from(result.logs).some((log) => log.event === 'Unlock'), 'Unlock is not emitted');
      })
      // test getLocked
      .then(() => ziomiTokenInstance.getLocked.call())
      .then((locked) => assert.equal(locked, false, 'getLocked returns ' + locked))
      // test create
      .then(() => ziomiTokenInstance.create(address, 1, {from: address}))
      .then((result) => assert.fail('Token created'))
      .catch((error) => assert.ok(error));
  });

  it('transfer', () => {
    const addressTo = '0x0000000000000000000000000000000000000002';
    const amount = 16;

    return ZiomiToken.deployed()
      .then((instance) => instance.transfer(addressTo, amount))
      .then((result) => {
        assert.equal(Boolean(result && result.tx), true, 'empty transaction hash');
        assert.ok(Array.from(result.logs).some((log) => log.event === 'Transfer'));
      })
      .then(() => ZiomiToken.deployed())
      .then((instance) => instance.balanceOf.call(addressTo))
      .then((balance) => assert.equal(balance.valueOf(), amount, 'balanceOf'));
  });
});
