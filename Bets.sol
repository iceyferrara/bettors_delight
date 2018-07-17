pragma solidity 0.4.24;

contract Bets {

    struct Team {
      uint id;
      string name;
      uint betCount;
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
