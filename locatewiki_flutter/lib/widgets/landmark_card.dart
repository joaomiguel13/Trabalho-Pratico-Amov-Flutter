import 'package:flutter/material.dart';
import 'package:locatewiki_flutter/widgets/landmark_details.dart';
import 'package:locatewiki_flutter/widgets/like_info.dart';
import 'package:locatewiki_flutter/widgets/map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:locatewiki_flutter/data_structs.dart';
import 'package:locatewiki_flutter/firebase_helper.dart';

class LandmarkCard extends StatefulWidget {
  const LandmarkCard({
    super.key,
    required this.landmark,
    required this.categories,
  });

  final Landmark landmark;
  final Set<Category> categories;

  @override
  State<LandmarkCard> createState() => _LandmarkCardState();
}

class _LandmarkCardState extends State<LandmarkCard> {
  String _likeStatus = "none";

  @override
  void initState() {
    _getSharedPreference('${widget.landmark.locationId}/${widget.landmark.id}')
        .then((value) => setState(() {
              _likeStatus = value ?? 'none';
            }));
    return super.initState();
  }

  Future<void> _setSharedPreference(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<String?> _getSharedPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _onLike() async {
    String? likeStatus = await _getSharedPreference(
        '${widget.landmark.locationId}/${widget.landmark.id}');
    if (likeStatus == 'disliked') {
      return;
    }

    int newNumLikes = widget.landmark.numLikes + 1;
    String newLikeStatus = 'liked';
    if (likeStatus == 'liked') {
      newLikeStatus = 'none';
      newNumLikes = widget.landmark.numLikes - 1;
    }

    FirebaseHelper().updateLandmarkLike(
        widget.landmark.locationId, widget.landmark.id, newNumLikes);
    await _setSharedPreference(
        '${widget.landmark.locationId}/${widget.landmark.id}', newLikeStatus);
    setState(() {
      _likeStatus = newLikeStatus;
    });
  }

  Future<void> _onDislike() async {
    String? likeStatus = await _getSharedPreference(
        '${widget.landmark.locationId}/${widget.landmark.id}');
    if (likeStatus == 'liked') {
      return;
    }

    int newNumDislikes = widget.landmark.numDislikes + 1;
    String newLikeStatus = 'disliked';
    if (likeStatus == 'disliked') {
      newLikeStatus = 'none';
      newNumDislikes = widget.landmark.numDislikes - 1;
    }

    FirebaseHelper().updateLandmarkDislike(
        widget.landmark.locationId, widget.landmark.id, newNumDislikes);
    await _setSharedPreference(
        '${widget.landmark.locationId}/${widget.landmark.id}', newLikeStatus);
    setState(() {
      _likeStatus = newLikeStatus;
    });
  }

  void _onViewMap() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MapPage(geoPoint: widget.landmark.geoPoint)));
  }

  void _addToHistory(String landmarkId) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('history') ?? [];

    // so that we don't have duplicates and so that the most recent is at the end
    if (history.contains(landmarkId)) {
      history.remove(landmarkId);
    }

    // remove all but the last 9
    while (history.length >= 10) {
      history.removeAt(0);
    }

    history.add(landmarkId);
    await prefs.setStringList('history', history);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LandmarkDetailsPage(
                    landmark: widget.landmark, categories: widget.categories)));
        _addToHistory(widget.landmark.id);
      },
      onSecondaryTap: () => showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: const Text('View Map'),
              onTap: () {
                Navigator.pop(context);
                _onViewMap();
              },
            ),
          ],
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        color: Theme.of(context).cardColor,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.landmark.title,
                            style: const TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.landmark.otherInfo,
                            style: const TextStyle(fontSize: 13.0),
                          ),
                          Text(
                            '${widget.landmark.geoPoint.latitude}, ${widget.landmark.geoPoint.longitude}',
                            style: const TextStyle(fontSize: 13.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(widget.categories
                                .firstWhere((category) =>
                                    widget.landmark.categoryId == category.id)
                                .icon
                                .icon),
                            const SizedBox(width: 8.0),
                            Text(
                              widget.categories
                                  .firstWhere((category) =>
                                      widget.landmark.categoryId == category.id)
                                  .getPresentationName(),
                              style: const TextStyle(fontSize: 13.0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        LikeInfo(
                          likeCount: widget.landmark.numLikes,
                          isLiked: _likeStatus == 'liked',
                          onLike: () => _onLike(),
                          dislikeCount: widget.landmark.numDislikes,
                          isDisliked: _likeStatus == 'disliked',
                          onDislike: () => _onDislike(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
