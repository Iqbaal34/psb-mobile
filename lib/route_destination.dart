import 'package:flutter/material.dart';
import 'package:inventaris_app/Dashboard.dart';
import 'notifiers/navbar_notifiers.dart';

class RouteDestination {
   static void GoToHome(BuildContext context, {required String nisn, required String nama}) {
    navIndexNotifier.value = 0;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardSiswa(nisn: nisn, nama: nama),
      ),
    );
  }


}

