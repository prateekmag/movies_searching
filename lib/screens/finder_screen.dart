import 'package:flutter/material.dart';
import 'package:task_assignment/services/movie.dart';
import 'package:task_assignment/utils/constants.dart';
import 'package:task_assignment/widgets/custom_loading_spin_kit_ring.dart';
import 'package:task_assignment/widgets/custom_search_appbar_content.dart';
import 'package:task_assignment/widgets/movie_card.dart';
import 'package:task_assignment/widgets/movie_card_container.dart';
import 'package:task_assignment/widgets/shadowless_floating_button.dart';
import 'package:sizer/sizer.dart';
import 'package:task_assignment/utils/scroll_top_with_controller.dart'
    as scrollTop;

class FinderScreen extends StatefulWidget {
  final Color themeColor;
  FinderScreen({required this.themeColor});
  @override
  _FinderScreenState createState() => _FinderScreenState();
}

class _FinderScreenState extends State<FinderScreen> {
  String textFieldValue = "";
  //for scroll upping
  late ScrollController _scrollController;
  bool showBackToTopButton = false;
  List<MovieCard>? _movieCards;
  bool showLoadingScreen = false;

  Future<void> loadData(String movieName) async {
    MovieModel movieModel = MovieModel();
    _movieCards = await movieModel.searchMovies(
        movieName: movieName, themeColor: widget.themeColor);

    setState(() {
      scrollTop.scrollToTop(_scrollController);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          showBackToTopButton = (_scrollController.offset >= 200);
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 18.h,
        title: Text(kFinderScreenTitleText, style: kSmallAppBarTitleTextStyle),
        backgroundColor: kSearchAppBarColor,
        shadowColor: Colors.transparent,
        bottom: PreferredSize(
          child: CustomSearchAppbarContent(
              onChanged: (value) => textFieldValue = value,
              onEditingComplete: () {
                if (textFieldValue.length > 0) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  showLoadingScreen = true;

                  setState(() {
                    _movieCards = null;
                    loadData(textFieldValue);
                  });
                }
              }),
          preferredSize: Size.zero,
        ),
      ),
      body: (_movieCards == null)
          ? ((showLoadingScreen)
              ? CustomLoadingSpinKitRing(loadingColor: widget.themeColor)
              : null)
          : (_movieCards!.length == 0)
              ? Center(
                  child: Text(
                  kNotFoundErrorText,
                  style: kSplashScreenTextStyle,
                ))
              : MovieCardContainer(
                  scrollController: _scrollController,
                  themeColor: widget.themeColor,
                  movieCards: _movieCards!,
                ),

    );
  }
}
