import 'package:cloud_firestore/cloud_firestore.dart';

class UserPerformance {
  final String userId;
  final String? userName;
  final String? userAvatar;
  final String topicId;
  final int correctAnswers;
  final DateTime timeTaken;
  final int completionCount;
  final DateTime lastStudied;

  UserPerformance({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.topicId,
    required this.correctAnswers,
    required this.timeTaken,
    required this.completionCount,
    required this.lastStudied,
  });

  factory UserPerformance.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return UserPerformance(
      userId: data['userId'],
      userName: data['userName'],
      userAvatar: data['userAvatar'],
      topicId: data['topicId'],
      correctAnswers: data['correctAnswers'] ?? 0,
      timeTaken: (data['timeTaken'] as Timestamp).toDate(),
      completionCount: data['completionCount'] ?? 0,
      lastStudied: (data['lastStudied'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'topicId': topicId,
      'correctAnswers': correctAnswers,
      'timeTaken': timeTaken,
      'completionCount': completionCount,
      'lastStudied': lastStudied,
    };
  }
}

Future<void> saveUserPerformance(
    String topicId,
    String userUid,
    String userName,
    String userAvatar,
    DateTime timeTaken,
    int numberOfCorrectAnswers,
    {bool updateCompletionCount = true}
    ) async {
  try {
    DocumentSnapshot accessSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .collection('access')
        .doc(userUid)
        .get();

    if (accessSnapshot.exists) {
      Map<String, dynamic>? data = accessSnapshot.data() as Map<String, dynamic>?;
      int currentCompletionCount = data?['completionCount'] ?? 0;
      DateTime lastStudied = (data?['lastStudied'] as Timestamp?)?.toDate() ?? DateTime.now();

      UserPerformance userPerformance = UserPerformance(
        userId: userUid,
        topicId: topicId,
        correctAnswers: numberOfCorrectAnswers,
        timeTaken: timeTaken,
        completionCount: updateCompletionCount ? currentCompletionCount + 1 : currentCompletionCount,
        lastStudied: lastStudied,
        userName: userName,
        userAvatar: userAvatar,
      );

      await accessSnapshot.reference.set(userPerformance.toMap());
      print('User performance updated successfully');
    } else {
      UserPerformance userPerformance = UserPerformance(
        userId: userUid,
        topicId: topicId,
        correctAnswers: numberOfCorrectAnswers,
        timeTaken: timeTaken,
        completionCount: 0,
        lastStudied: DateTime.now(),
        userName: userName,
        userAvatar: userAvatar,
      );

      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('access')
          .doc(userPerformance.userId)
          .set(userPerformance.toMap());
      print('User performance saved successfully');
    }
  } catch (e) {
    print('Error saving user performance: $e');
  }
}






