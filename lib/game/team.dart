import 'package:info2051_2018/game/character.dart';

enum TeamStat{damage_dealt, damage_taken, killed, alive, damage_self_dealt, self_killed}

class Team{
  final Map<TeamStat, double> _stats = {
    TeamStat.damage_dealt:0,
    TeamStat.damage_taken:0,
    TeamStat.alive:0,
    TeamStat.killed:0,
    TeamStat.self_killed:0,
    TeamStat.damage_self_dealt:0,
};

  int teamId;
  String teamName;
  int _initialNbOfCharacters;

  List<Character> characters = List();

  Team(this.teamId, this.teamName, nbOfCharacters){
    this._initialNbOfCharacters = nbOfCharacters;
  }

  void addCharacter(Character c){
    characters.add(c);
  }

  void removeCharacter(Character c){
    characters.remove(c);
  }

  int get length{
    return characters.length;
  }

  Character getCharacter(int index){
    return characters[index];
  }

  void updateStats(TeamStat stat, double amount, {int teamTakingAttack}){
    if(stat == TeamStat.damage_dealt && teamTakingAttack == teamId)
      stat = TeamStat.damage_self_dealt;
    else if(stat == TeamStat.killed && teamTakingAttack == teamId)
      stat = TeamStat.self_killed;

    _stats[stat] += amount;
  }

  Map<TeamStat, double> computeStats(){
    _stats[TeamStat.alive] = (_initialNbOfCharacters - this.length).toDouble();

    for(Character c in characters)
      _stats[TeamStat.damage_taken] += (Character.base_hp - c.hp);

    return _stats;
  }
}