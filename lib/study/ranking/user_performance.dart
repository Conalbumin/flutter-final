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
      correctAnswers: data['correctAnswers'],
      timeTaken: data['timeTaken'].toDate(),
      completionCount: data['completionCount'],
      lastStudied: data['lastStudied'].toDate(),
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
