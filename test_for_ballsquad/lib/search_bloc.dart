import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_for_ballsquad/search_event.dart';
import 'package:test_for_ballsquad/search_state.dart';


class SearchBloc extends Bloc<SearchEvent, SearchState>{
  SearchBloc(): super(InitialState()){
    on<SearchWord>((event, emit) {

    });
  }
}