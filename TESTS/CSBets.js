var CSBets = artifacts.require("./CSBets.sol");

contract("CSBets", function(accounts) {
  var csbetsInstance;

  var creatorAddress = accounts[0];
  var bettor1Address = accounts[1];
  var bettor2Address = accounts[2];
  var bettor3Address = accounts[3];

  it("Should revert tx when not owner calls startMatch function", function() {
    return CSBets.deployed()
      .then(instance => {
        return instance.startMatch("OpTic","EG",{from:bettor2Address});
      })
      .then(result => {
        assert.fail();
      })
      .catch(error => {
        assert.notEqual(error.message, "assert.fail()", "TX was not reverted, match was created")
      });
  });
});
