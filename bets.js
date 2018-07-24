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

  it("allows a bettor to place a bet", function() {
    return Bets.deployed().then(function(instance) {
      betsInstance = instance
      teamId = 1;
      return betsInstance.placeBet(teamId, { from: accounts[0] });
    }).then(function(receipt) {
      assert.equal(receipt.logs.length, 1, "an event was triggered");
      assert.equal(receipt.logs[0].event, "bettedEvent", "the event type is correct");
  //    assert.equal(receipt.logs[0].args._teamId.toNumber(), teamId, "the team id is correct");
      return betsInstance.bettors(accounts[0]);
    }).then(function(betted) {
      assert(betted, "the bettor was marked as placing their bet");
      return betsInstance.teams(teamId);
    }).then(function(team) {
      var betCount = team[2];
      assert.equal(betCount, 1, "increments the teams bet count");
    })
  });

  it("throws an exception for invalid team", function() {
    return Bets.deployed().then(function(instance) {
      betsInstance = instance;
      return betsInstance.placeBet(99, { from: accounts[1] })   //Vote 1 time for team 99 (there is no team 99 at this point)
    }).then(assert.fail).catch(function(error) {
      assert(error.message.indexOf('revert') >= 0, "error message must contain revert");
      return betsInstance.teams(1);
    }).then(function(team1) {
      var betCount = team1[2];
      assert.equal(betCount, 1, "team 1 did not receive any votes");
      return betsInstance.teams(2);
    }).then(function(team2) {
      var betCount = team2[2];
      assert.equal(betCount, 0, "team s2 did not receive any votes");
    });
  });

  it("throws an exception for double betting", function() {
    return Bets.deployed().then(function(instance) {
      betsInstance = instance;
      teamId = 2;
      betsInstance.placeBet(teamId, { from: accounts[1] });
      return betsInstance.teams(teamId);
    }).then(function(team) {
      var betCount = team[2];
      assert.equal(betCount, 1, "accepts first bet");
      // Try to vote again
      return betsInstance.placeBet(teamId, { from: accounts[1] });
    }).then(assert.fail).catch(function(error) {
      assert(error.message.indexOf('revert') >= 0, "error message must contain revert");
      return betsInstance.teams(1);
    }).then(function(team1) {
      var betCount = team1[2];
      assert.equal(betCount, 1, "team 1 did not receive any votes");
      return betsInstance.teams(2);
    }).then(function(team2) {
      var betCount = team2[2];
      assert.equal(betCount, 1, "team2 did not receive any votes");
    });
  });
});
