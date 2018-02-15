// Unit Tests for Casino.sol
var Casino = artifacts.require("Casino");

contract('Casino', function(accounts) {
  it("should say new player doesn't exist", async function() {
    const casino = await Casino.new(10);
    const existence = await casino.checkPlayerExists.call(accounts[0]);
    assert(existence == false);
  });
});
