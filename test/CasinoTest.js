// Unit Tests for Casino.sol
var Casino = artifacts.require("Casino");

contract('Casino', function(accounts) {
  it("should say new player doesn't exist", async function() {
    const casino = await Casino.deployed();
    const existence = await casino.checkPlayerExists.call(accounts[0], {from: accounts[0]});
    assert(existence === false);
  });

  it("should accept a few bets and accumulate state properly", async function() {
    const casino = await Casino.deployed();
    const betAmt = 1;
    const betNumber = 4;
    for(var i=0; i<accounts.length; i++) {
      await casino.bet(betNumber, {from: accounts[i], value: betAmt});
    }
    const totalBet = await casino.totalBet.call();
    assert.equal(totalBet.toNumber(), betAmt * accounts.length);
  });
});
