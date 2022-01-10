
import 'package:bt_assignment/models/matches_history.dart';
import 'package:bt_assignment/services/matches_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'matches_repo_state.dart';



class MatchesRepoCubit extends Cubit<MatchesRepoState> {

  MatchesRepoCubit() : super(MatchesRepoState( teamWithMostWins: null, status: MatchesRepoStatus.initial));

  void fetching() async {
    emit (MatchesRepoState(status: MatchesRepoStatus.loading)) ;
    final matchservices = MatchServices();
    try {
      await matchservices.computeTeamWithMostWins();
      emit (MatchesRepoState(status:MatchesRepoStatus.success , teamWithMostWins : matchservices.teamWithMostWins()));
    }
    catch (e){
      print (e);
      emit(MatchesRepoState(status: MatchesRepoStatus.failure));
    }

  }

}
