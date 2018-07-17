pragma solidity 0.4.24;

contract Bets {
//Info from HLTV for team will go in this struct
    struct Team {
      uint id;   //match id?
      string name; //team name
      uint betCount; //Amount?
    }
// Read/write candidate
  mapping(uint => Team) public teams;

  uint public numberOfTeams;

// Constructor
  function Bets () public {
    addTeam("FAZE");
    addTeam("Astralis");
    addTeam("Virtus Pro");
    addTeam("Ninjas in Pyjamas");
    addTeam("Liquid");
    addTeam("NAVI");
    addTeam("EnvyUS");
    addTeam("Fnatic");
  }

  function addTeam (string _name) private {
    numberOfTeams++;
    teams[numberOfTeams] = Team(numberOfTeams, _name, 0);
  }
}
