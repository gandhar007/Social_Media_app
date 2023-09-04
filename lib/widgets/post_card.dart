import 'package:flutter/material.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/comments_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({super.key, required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {

  bool isLikeAnimating = false;

  @override
  Widget build(BuildContext context) {

    final User user = Provider.of<UserProvider>(context).getUser;

    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16).copyWith(right: 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(widget.snap['profImage']),
                  ),
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.snap['username'], style: const TextStyle(fontWeight: FontWeight.bold ),)
                          ],
                        ),
                      )
                  ),
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: ListView(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shrinkWrap: true,
                                children: [
                                  'Delete',
                                  'Report',
                                  'Save'
                                ]
                                    .map((e) => InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    child: Text(e),
                                  ),
                                ),
                                ).toList(),
                              ),
                            )
                        );
                      },
                      icon: const Icon(Icons.more_vert)
                  )
                ],
              ),
            ),
            // Image Section
            const SizedBox(height: 8,),
            GestureDetector(
              onDoubleTap: () async {
                await FirestoreMethods().likePost(
                    widget.snap['postId'],
                    user.uid,
                    widget.snap['likes'],
                    true
                );
                setState(() {
                  isLikeAnimating = true;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.35,
                    width: double.infinity,
                    child: Image.network(
                      widget.snap['postUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),

                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isLikeAnimating ? 1 : 0,
                    child: LikeAnimation(
                        isAnimating: isLikeAnimating,
                        duration: const Duration(milliseconds: 400),
                        onEnd: () {
                          setState(() {
                            isLikeAnimating = false;
                          });
                        },
                        child: const Icon(Icons.favorite, color: Colors.white, size: 100,)
                    ),
                  )
                ]
              ),
            ),

            // Like and comments section
            Row(
              children: [
                LikeAnimation(
                  isAnimating: widget.snap['likes'].contains(user.uid),
                  smallLike: true,
                  child: IconButton(
                      padding: const EdgeInsets.only(left: 12),
                      onPressed: () async {
                        await FirestoreMethods().likePost(
                            widget.snap['postId'],
                            user.uid,
                            widget.snap['likes'],
                            false
                        );
                      },
                      icon: widget.snap['likes'].contains(user.uid) ?
                      Icon(Icons.favorite, color: Colors.red[800])
                          : const Icon(Icons.favorite_border)
                  ),
                ),
                IconButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const CommentsScreen()))
                    ,
                    icon: const Icon(Icons.comment_outlined)
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.send)
                ),
                Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        padding: const EdgeInsets.only(right: 12),
                        onPressed: () {},
                        icon: const Icon(Icons.bookmark_border),
                      ),
                    )
                )
              ],
            ),

            // Description and number of comments
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(fontWeight: FontWeight.w800),
                    child: Text(
                      '${widget.snap['likes'].length} likes',
                      style: Theme.of(context).textTheme.bodyText2
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 8),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: primaryColor),
                        children: [
                          TextSpan(
                            text: widget.snap['username'],
                            style: const TextStyle(fontWeight: FontWeight.bold)
                          ),
                          TextSpan(
                              text: '  ${widget.snap['description']}',
                          ),
                        ]
                      ),
                    ),
                  ),

                  // Comments
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: const Text(
                          'View all 200 comments',
                          style: TextStyle(
                          fontSize: 14.5,
                          color: secondaryColor
                        ),
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                        DateFormat.yMMMd().format(widget.snap['datePublished'].toDate()),
                        style: const TextStyle(
                        fontSize: 14.5,
                        color: secondaryColor
                    ),
                  ),
                  )
                ],
              ),
            )
          ],
      ),
    );
  }
}