import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_news_app/core/error/failure.dart';
import 'package:flutter_news_app/feature/domain/usecase/gettopheadlinesnews/get_top_headlines_news.dart';
import 'package:flutter_news_app/feature/domain/usecase/searchtopheadlinesnews/search_top_headlines_news.dart';
import 'package:meta/meta.dart';

import './bloc.dart';

class TopHeadlinesNewsBloc extends Bloc<TopHeadlinesNewsEvent, TopHeadlinesNewsState> {
  final GetTopHeadlinesNews getTopHeadlinesNews;
  final SearchTopHeadlinesNews searchTopHeadlinesNews;

  TopHeadlinesNewsBloc({
    @required this.getTopHeadlinesNews,
    @required this.searchTopHeadlinesNews,
  })  : assert(getTopHeadlinesNews != null),
        assert(searchTopHeadlinesNews != null),super(InitialTopHeadlinesNewsState()){
    on<LoadTopHeadlinesNewsEvent>(_onLoad);
  }

  @override
  TopHeadlinesNewsState get initialState => InitialTopHeadlinesNewsState();

  Stream<TopHeadlinesNewsState> mapEventToState(
    TopHeadlinesNewsEvent event,
  ) async* {
    if (event is LoadTopHeadlinesNewsEvent) {
      yield* _mapLoadTopHeadlinesNewsEventToState(event);
    } else if (event is ChangeCategoryTopHeadlinesNewsEvent) {
      yield* _mapChangeCategoryTopHeadlinesNewsEventToState(event);
    } else if (event is SearchTopHeadlinesNewsEvent) {
      yield* _mapSearchTopHeadlinesNewsEventToState(event);
    }
  }

  void _onLoad(
      LoadTopHeadlinesNewsEvent event,
      Emitter<TopHeadlinesNewsState> emit,
      ) async {
    emit(LoadingTopHeadlinesNewsState());

    var response = await getTopHeadlinesNews(ParamsGetTopHeadlinesNews(page: event.page, language: event.language));
    response.fold((failure) {
        if (failure is ServerFailure) {
          emit(FailureTopHeadlinesNewsState(errorMessage: failure.errorMessage));
        } else if (failure is ConnectionFailure) {
          emit(FailureTopHeadlinesNewsState(errorMessage: failure.errorMessage));
        }
      },
          (data) => emit(LoadedTopHeadlinesNewsState(listArticles: data)),
    );
  }

  Stream<TopHeadlinesNewsState> _mapLoadTopHeadlinesNewsEventToState(LoadTopHeadlinesNewsEvent event) async* {
    yield LoadingTopHeadlinesNewsState();
    var response = await getTopHeadlinesNews(ParamsGetTopHeadlinesNews(page: event.page));
    yield response.fold(
      // ignore: missing_return
      (failure) {
        if (failure is ServerFailure) {
          return FailureTopHeadlinesNewsState(errorMessage: failure.errorMessage);
        } else if (failure is ConnectionFailure) {
          return FailureTopHeadlinesNewsState(errorMessage: failure.errorMessage);
        }
      },
      (data) => LoadedTopHeadlinesNewsState(listArticles: data),
    );
  }

  Stream<TopHeadlinesNewsState> _mapChangeCategoryTopHeadlinesNewsEventToState(
    ChangeCategoryTopHeadlinesNewsEvent event,
  ) async* {
    yield ChangedCategoryTopHeadlinesNewsState(indexCategorySelected: event.indexCategorySelected);
  }

  Stream<TopHeadlinesNewsState> _mapSearchTopHeadlinesNewsEventToState(SearchTopHeadlinesNewsEvent event) async* {
    yield LoadingTopHeadlinesNewsState();
    var result = await searchTopHeadlinesNews(ParamsSearchTopHeadlinesNews(keyword: event.keyword));
    yield result.fold(
      // ignore: missing_return
      (failure) {
        if (failure is ServerFailure) {
          return FailureTopHeadlinesNewsState(errorMessage: failure.errorMessage);
        } else if (failure is ConnectionFailure) {
          return FailureTopHeadlinesNewsState(errorMessage: failure.errorMessage);
        }
      },
      (response) => SearchSuccessTopHeadlinesNewsState(listArticles: response.articles),
    );
  }
}
