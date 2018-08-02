var CSBets = artifacts.require("./CSBets.sol");

contract("CSBets", function(accounts) {
  var csbetsInstance;

  var creatorAddress = accounts[0];
  var bettor1Address = accounts[1];
  var bettor2Address = accounts[2];
  var bettor3Address = accounts[3];

  it("Should revert tx when not owner address calls startMatch function", function() {
    return CSBets.deployed()
      .then(instance => {
        return instance.startMatch("OpTic","VGJ.Storm",{from:bettor1Address});
      })
      .then(result => {
        assert.fail();
      })
      .catch(error => {
        assert.notEqual(error.message, "assert.fail()", "TX was not reverted, match was created");
      });
  });


  it("Should create a match with OpTic as team1, and EG as team2", function(){
    return CSBets.deployed()
    .then(instance => {
      return instance.startMatch("OpTic","EG",{from:creatorAddress});
    })
    .catch(error => {
      assert.fail("TX was reverted with an invalid address, match not created");
    });
  });


  it("Should fail to place a bet from account 1 due to not enough ether", function(){
    return CSBets.deployed()
    .then(instance => {
      return instance.startBet(1,1,{from:bettor1Address, value:web3.toWei(0.001, "ether")});
    })
    .then(result => {
      assert.fail();
    })
    .catch(error => {
      assert.notEqual(error.message,"assert.fail()","TX was sent, bet placed");
    });
  });


  it("Should place a bet on match 1 for 3 ether from account 1", function(){
    return CSBets.deployed()
    .then(instance => {
      return instance.startBet(1,1,{from:bettor1Address, value:web3.toWei(3, "ether")});
    })
    .catch(error => {
      assert.fail("TX not sent, bet not placed.");
    });
  });

  it("Should place a bet on match 1 for 3 ether from account 1", function(){
    return CSBets.deployed()
    .then(instance => {
      return instance.startBet(2,1,{from:bettor1Address, value:web3.toWei(8, "ether")});
    })
    .catch(error => {
      assert.fail("TX not sent, bet not placed.");
    });
  });

  it("Ending betting for a match should only be done by an owner", function(){
    return CSBets.deployed()
    .then(instance => {
      return instance.endBetting(1, {from:creatorAddress});
    })
    .catch(error => {
      assert.fail("Transaction reverted, betting is still open.");
    });
  });


  it("Picking a winner should only be done by an owner", function(){
    return CSBets.deployed()
    .then(instance => {
      return instance.pickWinner(1, 1, {from:creatorAddress});
    })
    .catch(error => {
      assert.fail("Transaction reverted, Winning team not picked.");
    });
  });


  it("Should let bettor call calculateResults", function(){
      return CSBets.deployed()
        .then(instance => {
        return instance.calculateResults(1, {from:bettor1Address});
      })
      .catch(error => {
              assert.fail("Transaction reverted, calculateResults not call.");
      });
    });

  it("Should fail to let bettor call calculateResults more than once yupppp", function(){
      return CSBets.deployed()
      .then(instance => {
        return instance.calculateResults(1, {from:bettor1Address});
      })
      .then(result => {
        assert.fail();
      })
      .catch(error => {
        assert.notEqual(error.message,"assert.fail()","TX was sent, bettor allowed to call calculateResults more than once");
      });
    });


});
