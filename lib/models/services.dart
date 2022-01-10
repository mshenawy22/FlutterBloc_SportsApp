import 'dart:collection';
import 'dart:core';
export 'package:intl/intl.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'matches_history.dart' hide Duration;



class Team extends Equatable{
  Team({required  this.name , required  this.numofWins});

  final String name;
  final int numofWins;

  @override
  List<Object?> get props =>[ this.name , this.numofWins];
}


class  MatchServices   {
  late Team _teamWithMostWins ;

  static const _baseUrl = 'api.football-data.org';
  static const String _GET_MATCHES = '/v2/competitions/2021/matches/';
  static const Map<String, String> _QUERY_PARAMS =
  {
    'dateFrom' : '2021-10-08',
    'dateTo'   : '2022-01-09',
    'status'   :  'FINISHED'
  };


  DateToday(){
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(DateTime.now());

  }


  Date30daysAgo(){

    DateFormat formatter = DateFormat('yyyy-MM-dd');

    DateTime _date = DateTime.now().subtract(Duration(days: 30));
    return formatter.format(_date);
  }


  Future<MatchesHistory> getMatchesList() async {

    var queryParams = {
      'dateFrom' : Date30daysAgo(),
      'dateTo'   :  DateToday(),
      'status'   :  'FINISHED'

    };
    Uri uri = Uri.https(_baseUrl, _GET_MATCHES , queryParams);

    developer.log(uri.toString(), name: 'just logging');
    print(uri.toString());

    final response = await http.get(
      uri,
      headers: {
        'X-Auth-Token': 'cd029676c88b495da48839aefb25702c',
      },
    );

    MatchesHistory _matchesHistory = await MatchesHistory.fromJson(response.body);
    return _matchesHistory ;

  }

  computeTeamWithMostWins() async
  {
    var _matchesHistory = await getMatchesList();
    var matchWinners = await createWinnerTable(_matchesHistory);
    matchWinners     = sortWinnerTablesbyWins(matchWinners);
    _teamWithMostWins = Team (name : matchWinners.entries.first.key, numofWins: matchWinners.entries.first.value) ;


    print('Team with most wins is ${_teamWithMostWins.name}  with ${_teamWithMostWins.numofWins} wins  ');

  }


  createWinnerTable(MatchesHistory _matchesHistory ) async
  {
    Map matchWinners = Map <String, int>();

    if (_matchesHistory != null)
    {


      _matchesHistory.matches!.forEach((match) {

        switch (match.score!.winner) {

          case Winner.AWAY_TEAM:
            // matchWinners[Team(id : match.awayTeam?.id ,name: match.awayTeam?.name)]  ==null ? 0 :  CountaWin() ;
            matchWinners[match.awayTeam?.name] =
            ( matchWinners[match.awayTeam?.name] == null ?0 : ++matchWinners[match.awayTeam?.name]);
            // developer.log( ( '${match.awayTeam!.name} : No of wons  ${  matchWinners[match.awayTeam?.name]}');
            break;

          case Winner.HOME_TEAM:
            matchWinners[match.homeTeam?.name] =
            ( matchWinners[match.homeTeam?.name] == null ? 0 : ++matchWinners[match.homeTeam?.name]);

             // developer.log('${match.homeTeam?.name} : No of wons ${matchWinners[match.homeTeam?.name]}');
            break;
          case Winner.DRAW:
            //do nothing
            break;
        }

      });
    }
    else {
      developer.log('null _matchesHistory', name: 'null Errors' );

    }

    return matchWinners;


  }

  sortWinnerTablesbyWins(Map <String, int> matchWinners)
  {

      var sortedEntries = matchWinners.entries.toList()..sort((e1, e2) {
        var diff = e2.value.compareTo(e1.value);
        if (diff == 0) diff = e2.key.compareTo(e1.key);
        return diff;
      });

      matchWinners..clear()..addEntries(sortedEntries);

      return matchWinners;
  }

  Team teamWithMostWins()
  {
    return _teamWithMostWins ;
  }




}



