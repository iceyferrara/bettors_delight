pragma solidity ^0.4.24;
//Chris Bergamasco
//Michael Ferrara


contract CSBets {
  enum Team {NONE,TEAM1,TEAM2}

  address public owner; //address of owner
  //model of a Match
  struct Match{
    uint id; //id of match
    string team1;
    string team2;
    uint256 t1_pool; //pool for team1 bets
    uint256 t2_pool; //pool for team2 bets
    uint256 betPool; //total pool of bets
    bool betsOpen;
    Team winner;
  }
  struct Bet {
    uint matchID; //matchID
    Team team;
    uint256 amount;
  }

  struct bets_info{
    uint160 total_bet; //total amount of bets
    bool rewarded; //flag for doublespend
    mapping(bytes32 => uint) bets; //array of bets
  }

  mapping(uint => Match) public matches;
  mapping(address => Bet) public bets;
  mapping(uint => bets_info) public payoutIndex;

  uint matchCount;

//constructor
  constructor() public payable {
    owner = msg.sender;
  }

  function startMatch(string t1, string t2) onlyOwner {
  matchCount++;
  Team team = Team.NONE;
  matches[matchCount] = Match(matchCount, t1, t2, 0, 0, 0, true, team);
  }

  function startBet(uint _choice, uint _id) payable public {

    require(msg.value >= 0.01 ether);
    require(_choice == 1 || _choice == 2);
    require(matches[_id].id != 0);
    require(matches[_id].betsOpen == true);


    uint256 _amount = msg.value;
    Team _teamPicked = Team.NONE;

    if(_choice == 1){
      _teamPicked = Team.TEAM1;
      matches[_id].t1_pool += _amount;
    } else if(_choice == 2){
      _teamPicked = Team.TEAM2;
      matches[_id].t2_pool += _amount;
    }
    matches[_id].betPool += _amount;

    bets[msg.sender] = Bet(
      _id,
      _teamPicked,
      _amount
    );

  }


  function endBetting(uint _matchID) onlyOwner {
    require(matches[_matchID].id != 0);
    require(matches[_matchID].betsOpen == true);
    matches[_matchID].betsOpen = false;
  }

  function pickWinner(uint _matchID, uint _winner) onlyOwner {
    require(_winner == 1 || _winner == 2);
    require(matches[_matchID].id != 0);
    require(matches[_matchID].betsOpen == false);
    Team winningTeam = Team.NONE;
    if(_winner == 1) {
    matches[_matchID].winner = winningTeam;
    winningTeam = Team.TEAM1;
    } else {
      winningTeam = Team.TEAM2;
      matches[_matchID].winner = winningTeam;
    }
  }

  modifier onlyOwner {
    require(owner == msg.sender);
    _;
  }
}
