pragma solidity ^0.4.24;


//Chris Bergamasco
//Michael Ferrara
import "installed_contracts/oraclize-api/contracts/usingOraclize.sol";

contract CSBets is usingOraclize {
  //enum Team {NONE,TEAM1,TEAM2}
  event PrintJson(string data);

  address public owner; //address of owner
  //model of a Match
  struct Match{
    uint id; //id of match
    string theWinner; //String for Json data to pick winner of each specific match
    string team1;
    string team2;
    uint256 t1_pool; //pool for team1 bets
    uint256 t2_pool; //pool for team2 bets
    uint256 betPool; //total pool of bets
    uint256 house;
    bool betsOpen;
    string winner;
  }

  struct Bet {
    uint matchID; //matchID
    string team;
    uint256 amount;
  }

  struct bets_info{
    uint160 total_bet; //total amount of bets
    bool rewarded; //flag for doublespend
    mapping(bytes32 => uint) bets; //array of bets
  }

  struct OraclizeQueries{
      //uint id;
      string result;
  }

  //Store accounts that have placed bets. Used to make sure
  //that users dont call CalculateResults more than once
  mapping(address => bool) public bettors;

  mapping(uint => Match) public matches;
  mapping(address => Bet) public bets;
  mapping(uint => bets_info) public payoutIndex;
  mapping(bytes32 => OraclizeQueries) public validIDs;

  uint matchCount;

  string public jsonData;
  bytes32 oraclizeID;

  string public testString = "json(https://api.pandascore.co/dota2/matches.json?filter[id]=52365&token=tU9uGM46ds_tXnE6FkW3u9g43EV1HsfuXOBPVNkmPHOBzMDK13Q).0.winner.name";
  string public firstHalfQuery ="json(https://api.pandascore.co/dota2/matches.json?filter[id]=";
  string public secondHalfQuery ="&token=tU9uGM46ds_tXnE6FkW3u9g43EV1HsfuXOBPVNkmPHOBzMDK13Q).0.winner.name";

  //constructor
  constructor() public payable {
    owner = msg.sender;
    OAR = OraclizeAddrResolverI(0x6f485c8bf6fc43ea212e93bbf8ce046c7f1cb475);
    oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
  }

  function fetchMatchResults(uint _matchID) payable onlyOwner {
        bytes32 queryId = oraclize_query("URL",  strConcat(firstHalfQuery, uint2str(_matchID), secondHalfQuery));
        validIDs[queryId] = OraclizeQueries("");
        pickWinner(_matchID, validIDs[queryId].result);
      }

  function __callback(bytes32 oracleID, string result){
    if(msg.sender != oraclize_cbAddress()) revert();
    require(bytes(validIDs[oracleID].result).length == 0);
    validIDs[oracleID].result = result;
}

  function startMatch(string t1, string t2, uint matchID) onlyOwner {
  matchCount++;
  matches[matchCount] = Match(matchID, testString, t1, t2, 0, 0, 0, 0, true, "none");
}

  function startBet(string _choice, uint _id) payable public {

  require(msg.value >= 0.01 ether);
  require( compareStrings(_choice, matches[_id].team1) == true || compareStrings(_choice, matches[_id].team2) == true);
  require(matches[_id].id != 0);
  require(matches[_id].betsOpen == true);


  uint256 _amount = msg.value;
  uint256 _house = (_amount * 5) / 100;

  _amount = _amount - _house;
  matches[_id].house += _house;

  string memory _teamPicked;
  _teamPicked = "none";

  if(compareStrings(_choice,matches[_id].team1) == true){
    _teamPicked = matches[_id].team1;
    matches[_id].t1_pool += _amount;
  } else if(compareStrings(_choice,matches[_id].team2) == true){
    _teamPicked = matches[_id].team2;
    matches[_id].t2_pool += _amount;
  }
  matches[_id].betPool += _amount;

  bets[msg.sender] = Bet(
    _id,
    _teamPicked,
    _amount
    );
}

function compareStrings (string a, string b) view returns (bool){
     return keccak256(a) == keccak256(b);
}

function endBetting(uint _matchID) onlyOwner {
  require(matches[_matchID].id != 0);
  require(matches[_matchID].betsOpen == true);
  matches[_matchID].betsOpen = false;
}

function pickWinner(uint _matchID, string _winner) onlyOwner {
  require( compareStrings(_winner, matches[_matchID].team1) == true || compareStrings(_winner, matches[_matchID].team2) == true);
  require(matches[_matchID].id != 0);
  require(matches[_matchID].betsOpen == false);
  string memory winningTeam;
  winningTeam = "none";
  if(compareStrings(_winner, matches[_matchID].team1) == true) {
    winningTeam = matches[_matchID].team1;
    matches[_matchID].winner = winningTeam;
  } else {
    winningTeam = matches[_matchID].team2;
    matches[_matchID].winner = winningTeam;
  }
}

function calculateResults(uint _matchID) {
  //Require that the bettor hasnt called calculateResults anymore
  require(!bettors[msg.sender]);

  // Record that the bettor has called calculate Results
  bettors[msg.sender] = true;

  uint256 bettedAmount = bets[msg.sender].amount;
  uint256 team1Odds = matches[_matchID].t2_pool / matches[_matchID].t1_pool;
  uint256 team2Odds = matches[_matchID].t1_pool / matches[_matchID].t2_pool;
  uint256 winningAmount = 0;

  owner.transfer(matches[_matchID].house);
  if(compareStrings(matches[_matchID].winner,matches[_matchID].team1) == true && compareStrings(bets[msg.sender].team, matches[_matchID].team1) == true){
      winningAmount = team1Odds * bettedAmount + bettedAmount;
      msg.sender.transfer(winningAmount);
  } else if (compareStrings(matches[_matchID].winner,matches[_matchID].team2) == true && compareStrings(bets[msg.sender].team, matches[_matchID].team2) == true) {
      winningAmount = team2Odds * bettedAmount + bettedAmount;
      msg.sender.transfer(winningAmount);
  }
}

modifier onlyOwner {
  require(owner == msg.sender);
  _;
}
}
