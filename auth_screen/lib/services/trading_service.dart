import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class TradingService {
  final logger = Logger();

  Future<void> updateMoney(double profit) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference portfolioDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('portfolio')
          .doc('details');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(portfolioDocRef);
        if (snapshot.exists) {
          double currentMoney = (snapshot.get('money') ?? 0).toDouble();
          double newMoney = currentMoney + profit;
          logger.i('Current money: $currentMoney, New money: $newMoney');
          transaction.update(portfolioDocRef, {'money': newMoney});
        } else {
          logger.w('Document does not exist.');
        }
      });
    } else {
      throw Exception("User not logged in.");
    }
  }

  Future<void> updatePoints(double points) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference portfolioDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('portfolio')
          .doc('details');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(portfolioDocRef);
        if (snapshot.exists) {
          double currentPoints = (snapshot.get('points') ?? 0).toDouble();
          double newPoints = currentPoints + points;
          logger.i('Current points: $currentPoints, New points: $newPoints');
          transaction.update(portfolioDocRef, {'points': newPoints});
        } else {
          logger.w('Document does not exist.');
        }
      });
    } else {
      throw Exception("User not logged in.");
    }
  }
}
