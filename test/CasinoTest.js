// Unit Tests for Casino.sol
var Casino = artifacts.require("Casino");

contract('Casino', function(accounts) {
  it("should say new player doesn't exist", async function() {
    const casino = await Casino.new();
    const existence = await casino.checkPlayerExists.call(accounts[0], {from: accounts[0]});
    assert(existence === false);
  });

  it("should say registered player does exist", async function() {
    const casino = await Casino.new();
    await casino.bet(5, {from: accounts[0], value: 1});
    const existence = await casino.checkPlayerExists.call(accounts[0], {from: accounts[0]});
    assert(existence === true);
  });

  it("should accept a few bets and accumulate state properly", async function() {
    const casino = await Casino.new();
    const betAmt = 1;
    const betNumber = 4;
    for(var i=0; i<accounts.length; i++) {
      await casino.bet(betNumber, {from: accounts[i], value: betAmt});
    }
    const totalBet = await casino.totalBet.call();
    assert.equal(totalBet.toNumber(), betAmt * accounts.length);
    const totalBetCount = await casino.numberOfBets.call();
    assert.equal(totalBetCount.toNumber(), accounts.length);
  });
});
