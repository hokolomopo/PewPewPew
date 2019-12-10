
import 'team.dart';

class GameStats{
  String winningTeam;
  Map<String, Map<TeamStat, double>> statistics;

  GameStats(this.winningTeam, this.statistics);
}