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
    uint160 t1_pool; //pool for team1 bets
    uint160 t2_pool; //pool for team2 bets
    uint160 betPool; //total pool of bets
    bool betsOpen;
  }
  struct Bet {
  //  uint id; //id of bet
    uint matchID; //matchID
    Team team;
    uint256 amount;
  //  uint betCount;
  }

  struct bets_info{
    uint160 total_bet; //total amount of bets
    bool rewarded; //flag for doublespend
    mapping(bytes32 => uint) bets; //array of bets
  }



  mapping(uint => Match) public matches;
  mapping(address => Bet) public bets;
  mapping(uint => pool_info) public poolIndex;
  mapping(uint => bets_info) public payoutIndex;

  uint matchCount;

//constructor
  function CSBets() public payable {
    owner = msg.sender;
  }

  function startMatch(string t1, string t2) onlyOwner {
  matchCount++;
  matches[matchesCount] = Matches(matchesCount, t1, t2, 0, 0, 0, true);
  }

  function startBet(uint _choice, uint _id) payable bettingOpen public{

    require(msg.value >= 0.01 ether);
    require(_choice == 1 || _choice == 2);
    require(matches[_id].id != 0);


    uint256 _amount = msg.value;
    Team _teamPicked = Team.NONE;

    if(_choice == 1){
      _teamPicked = Team.TEAM1;
      matches.t1_pool += _amount;
    } else if(_choice == 2){
      _teamPicked = Team.TEAM2;
      matches.t2_pool += _amount;
    }

    bets[msg.sender] = Bet(
      _id,
      _teamPicked,
      _amount
    );



  }

  modifier onlyOwner {
    require(owner == msg.sender);
    _;
  }
  modifier bettingOpen{
    require(matches.betsOpen);
    _;
  }
}
