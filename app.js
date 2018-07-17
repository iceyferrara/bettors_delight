App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',

  init: function() {
    return App.initWeb3();
  },
//Initializing Web3 connects our client-side application to our blockchain
  initWeb3: function() {
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("Bets.json", function(bets) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.Bets = TruffleContract(bets);
      // Connect provider to interact with contract
      App.contracts.Bets.setProvider(App.web3Provider);

      return App.render();
    });
  },

  render: function() {
    var betsInstance;
    var loader = $("#loader");
    var content = $("#content");

    loader.show();
    content.hide();

    // Load account data
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);  //returning account of ethereum blockchain
      }
    });

    // Load contract data
    App.contracts.Bets.deployed().then(function(instance) {
      betsInstance = instance;
      return betsInstance.numberOfTeams();
    }).then(function(numberOfTeams) {
      var teamResults = $("#teamResults");
      teamResults.empty();

      for (var i = 1; i <= numberOfTeams; i++) {
        betsInstance.teams(i).then(function(team) {
          var id = team[0];
          var teamName = team[1];
          var betCount = team[2];

          // Render candidate Result
          var teamTemplate = "<tr><th>" + id + "</th><td>" + teamName + "</td><td>" + betCount + "</td></tr>"
          teamResults.append(teamTemplate);
        });
      }

      loader.hide();
      content.show();
    }).catch(function(error) {
      console.warn(error);
    });
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
