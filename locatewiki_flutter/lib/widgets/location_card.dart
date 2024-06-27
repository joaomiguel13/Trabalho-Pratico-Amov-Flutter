import 'package:flutter/material.dart';
import 'package:locatewiki_flutter/widgets/like_info.dart';
import 'package:locatewiki_flutter/widgets/map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:locatewiki_flutter/data_structs.dart';
import 'package:locatewiki_flutter/firebase_helper.dart';
import 'package:locatewiki_flutter/widgets/landmarks.dart';

class LocationCard extends StatefulWidget {
  const LocationCard({
    super.key,
    required this.location,
  });

  final Location location;

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  String _likeStatus = "none";

  @override
  void initState() {
    _getSharedPreference(widget.location.id).then((value) => setState(() {
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
    String? likeStatus = await _getSharedPreference(widget.location.id);
    if (likeStatus == 'disliked') {
      return;
    }

    int newNumLikes = widget.location.numLikes + 1;
    String newLikeStatus = 'liked';
    if (likeStatus == 'liked') {
      newLikeStatus = 'none';
      newNumLikes = widget.location.numLikes - 1;
    }

    FirebaseHelper().updateLocationLike(widget.location.id, newNumLikes);
    await _setSharedPreference(widget.location.id, newLikeStatus);
    setState(() {
      _likeStatus = newLikeStatus;
    });
  }

  Future<void> _onDislike() async {
    String? likeStatus = await _getSharedPreference(widget.location.id);
    if (likeStatus == 'liked') {
      return;
    }

    int newNumDislikes = widget.location.numDislikes + 1;
    String newLikeStatus = 'disliked';
    if (likeStatus == 'disliked') {
      newLikeStatus = 'none';
      newNumDislikes = widget.location.numDislikes - 1;
    }

    FirebaseHelper().updateLocationDislike(widget.location.id, newNumDislikes);
    await _setSharedPreference(widget.location.id, newLikeStatus);
    setState(() {
      _likeStatus = newLikeStatus;
    });
  }

  void _onViewMap() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MapPage(geoPoint: widget.location.geoPoint)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LandmarksPage(location: widget.location))),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.location.title,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            widget.location.otherInfo,
                            style: const TextStyle(fontSize: 13.0),
                          ),
                          Text(
                            '${widget.location.geoPoint.latitude}, ${widget.location.geoPoint.longitude}',
                            style: const TextStyle(fontSize: 13.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        LikeInfo(
                          likeCount: widget.location.numLikes,
                          isLiked: _likeStatus == 'liked',
                          onLike: () => _onLike(),
                          dislikeCount: widget.location.numDislikes,
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
