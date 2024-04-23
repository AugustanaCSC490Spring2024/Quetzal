import 'package:cloud_firestore/cloud_firestore.dart';
import 'questions.dart';

void updateFirestore() async {
  CollectionReference questionBank =
      FirebaseFirestore.instance.collection('questionbank');


  await questionBank.get().then((snapshot) {
    for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
  });


  for (var question in questionData) {
    await questionBank.add(question);
  }

}
