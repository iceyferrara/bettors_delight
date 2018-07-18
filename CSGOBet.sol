pragma solidity ^0.4.24;

import "./lib/usingOraclize.sol";
import "./lib/SafeMath.sol";

contract CSGOBet is usingOraclize {


    struct match_info{
      bool betting_open; // flag to check if betting is open
      bool match_start; // flag to check if match has started
      bool match_end; // flag to check if match has ended
      bool voided_bet; //flag to check if bet has been voided
      uint32 match_id; // int containing matchid provided by HLTV API via Oraclize
      uint32 starting_time; // timestamp of when the match starts
    }

    struct bet_info {
      bytes32 team; //team which amount is bet on
      uint amount; //amount bet by Bettor
    }
    struct team_info {
      uint160 total; //total coin pool
      uint32 count; //number of bets
      bytes32 TEAM1; //32byte of matches.TEAM1
      bytes32 TEAM2; //32byte of matches.TEAM2
      bool win_check;
      bytes32 OraclizeID;
    }

    struct voter_info {
      uint160 total_bet; //total amount of bets placed
      bool rewarded; // flag to check for double spending
      mapping(bytes32=>uint) bets; //array of bets
    }

    mapping (bytes32 => bytes32) oraclizeIndex; //mapping oraclize ids with teams(noideaifweneed)
    mapping (bytes32 => team_info) teamIndex; //mapping teams with pool information
    mapping (address => voter_info) voterIndex; //mapping voter address with Bettor information

    uint public total_reward; // total reward to be awarded
    uint32 total_bettors;
    mapping (bytes32 => bool) public winner_team;

    //tracking events
    event newOraclizeQuery(string description);
    event newPriceTicker(uint price);
    event Deposit(address _from, uint256 _value, bytes32 _)

    // constructor
    function CSGOBet() public payable {
      oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
      owner = msg.sender;
      oraclize_setCustomGasPrice(30000000000 wei);
      matches.
    }

    //data access structures
    match_info public matches;
    team_info public teams;

    //modifiers for restricting access to methods
    modifier onlyOwner {
      require(owner == msg.sender);
      _;
    }

    modifier duringBetting {
      require(matches.betting_open);
      require(now < matches.starting_time);
      _;
    }

    modifier afterMatch {
      require(matches.match_end);
      _;
    }

    //function to change changeOwnership
    function changeOwnership(address _newOwner) onlyOwner external {
      owner = _newOwner;
    }

    //oraclize callback method
    function __callback(bytes32 myid, string result, bytes proof) public {
      require (msg.sender == oraclize_cbAddress());
      require (!matches.match_end);
      // bytes32 team_pointer; //variable to differentiate different callbacks
      matches.match_start = true;
      matches.betting_open = false;
      bettingControllerInstace.remoteBettingClose();
      team_pointer = oraclizeIndex[myid];
    }

}
