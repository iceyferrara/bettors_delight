var Bets = artifacts.require("./Bets.sol");

contract("Bets", function(accounts) {
  var betsInstance;

  it("initializes with two teams", function() {
    return Bets.deployed().then(function(instance) {
      return instance.numberOfTeams();
    }).then(function(count) {
      assert.equal(count, 2);
    });
  });


  it("it initializes the teams with the correct values", function() {
    return Bets.deployed().then(function(instance) {
      betsInstance = instance;
      return betsInstance.teams(1);
    }).then(function(team) {
      assert.equal(team[0], 1, "contains the correct id");
      assert.equal(team[1], "FAZE", "contains the correct name");
      assert.equal(team[2], 0, "contains the correct votes count");
      return betsInstance.teams(2);
    }).then(function(team) {
      assert.equal(team[0], 2, "contains the correct id");
      assert.equal(team[1], "Astralis", "contains the correct name");
      assert.equal(team[2], 0, "contains the correct votes count");
    });
  });
});
