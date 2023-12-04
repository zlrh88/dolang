import 'dart:math';

import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dolang/models/database.dart';
import 'package:dolang/models/transaction_with_category.dart';
import 'package:dolang/pages/category_page.dart';
import 'package:dolang/pages/transaction_page.dart';
import 'package:money_formatter/money_formatter.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDb database = AppDb();

  MoneyFormatter fmf = MoneyFormatter(
      amount: 123456789.90235,
      settings: MoneyFormatterSettings(
        symbol: 'Rp',
      ));

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  // page controller

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Icon(
                                    Icons.download,
                                    color: Colors.greenAccent[400],
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Income',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 12, color: Colors.white)),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  FutureBuilder(
                                      future: database.sumAmount(2),
                                      builder: (context, snapshot) {
                                        CircularProgressIndicator();
                                        if (snapshot.hasData) {
                                          return Text(
                                              'Rp.' + snapshot.data!.toString(),
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 14,
                                                  color: Colors.white));
                                        } else if (snapshot.hasError)
                                          return Text(
                                              snapshot.error.toString());
                                        return Text('Belum ada Transaksi',
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                color: Colors.white));
                                      })
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Icon(
                                    Icons.upload,
                                    color: Colors.redAccent[400],
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Expense',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 12, color: Colors.white)),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  FutureBuilder(
                                      future: database.sumAmount(1),
                                      builder: (context, snapshot) {
                                        CircularProgressIndicator();
                                        if (snapshot.hasData) {
                                          return Text(
                                              'Rp.' + snapshot.data!.toString(),
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 14,
                                                  color: Colors.white));
                                        } else if (snapshot.hasError)
                                          return Text(
                                              snapshot.error.toString());
                                        return Text('Belum ada Transaksi',
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                color: Colors.white));
                                      })
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  )),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Transactions",
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<List<TransactionWithCategory>>(
                stream: database.getTransactionByDateRepo(widget.selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasData) {
                      if (snapshot.data!.length > 0) {
                        return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Card(
                                  elevation: 10,
                                  child: ListTile(
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () async {
                                              await database.deleteTransaction(
                                                  snapshot.data![index]
                                                      .transaction.id);
                                              setState(() {});
                                            }),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () async {
                                            setState(() {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        TransactionPage(
                                                            transactionsWithCategory:
                                                                snapshot.data![
                                                                    index]),
                                                  ))
                                                  .then((value) {});
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                    subtitle: Text(
                                        snapshot.data![index].category.name +
                                            ":" +
                                            snapshot.data![index].transaction
                                                .description),
                                    leading: Container(
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: (snapshot.data![index].category
                                                    .type ==
                                                1)
                                            ? Icon(
                                                Icons.download,
                                                color: Colors.greenAccent[400],
                                              )
                                            : Icon(
                                                Icons.upload,
                                                color: Colors.red[400],
                                              )),
                                    title: Text(
                                      fmf
                                          .copyWith(
                                              amount: snapshot.data![index]
                                                  .transaction.amount
                                                  .toDouble())
                                          .output
                                          .symbolOnLeft
                                          .toString(),
                                    ),
                                  ),
                                ),
                              );
                            });
                      } else {
                        return Center(
                          child: Column(children: [
                            SizedBox(
                              height: 30,
                            ),
                            Text("Belum ada transaksi",
                                style: GoogleFonts.montserrat()),
                          ]),
                        );
                      }
                    } else {
                      return Center(
                        child: Text("Belum ada transaksi"),
                      );
                    }
                  }
                })
          ],
        ),
      ),
    );
  }
}
