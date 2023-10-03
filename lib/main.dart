import 'dart:async';
import 'dart:developer';

import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  bool connected = false;
  List availableBluetoothDevices = [];

  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths!;
    });
  }

  Future<void> setConnect(String mac) async {
    final String? result = await BluetoothThermalPrinter.connect(mac);
    print("state conneected $result");
    if (result == "true") {
      setState(() {
        connected = true;
      });
    }
  }

  Future<void> printTicket() async {
    log('message');
    // List<VanSaleDetailModel> list = [
    //   VanSaleDetailModel(
    //       vanSaleDetails: [
    //         VanSaleDetail(
    //             productId: "12345678901234",
    //             description: "CarrotCarrotCarrotCarrot 123456789 CarrotCarrot")
    //       ],
    //       price: 2.5,
    //       quantity: 5,
    //       amount: 12.5,
    //       updatedUnit: UnitModel(code: "ok")),
    //   VanSaleDetailModel(
    //       vanSaleDetails: [
    //         VanSaleDetail(productId: "C50", description: "Cucumber")
    //       ],
    //       price: 2.5,
    //       quantity: 5,
    //       amount: 12.5,
    //       updatedUnit: UnitModel(code: "sss")),
    //   VanSaleDetailModel(
    //       vanSaleDetails: [
    //         VanSaleDetail(productId: "T4", description: "tomato")
    //       ],
    //       price: 2.5,
    //       quantity: 5,
    //       amount: 12.5,
    //       updatedUnit: UnitModel(code: "ok"))
    // ];

    // double tax = 2.0;
    // List<int> bytes = await getTicket(PrintHelper(
    //     vanName: "Demo dynamic",
    //     address: "addresses",
    //     phone: "9876543210",
    //     total: "",
    //     amountInWords: "",
    //     customer: "name",
    //     discount: "",
    //     footerImage: "",
    //     headerImage: "",
    //     invoiceNo: "",
    //     mobile: "9842222",
    //     paymentMode: "Cash",
    //     salesPerson: "person",
    //     refNo: "",
    //     tax: "$tax",
    //     subTotal: "",
    //     transactionDate: DateTime.now().toIso8601String(),
    //     trn: "",
    //     items: list));
    // final result = await BluetoothThermalPrinter.writeBytes(bytes);
    // print("Print $result");
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<VanSaleDetailModel> list = [
        VanSaleDetailModel(
            vanSaleDetails: [
              VanSaleDetail(
                  productId: "12345678901234",
                  description:
                      "CarrotCarrotCarrotCarrot 123456789 CarrotCarrot")
            ],
            price: 2.5,
            quantity: 5,
            amount: 12.5,
            updatedUnit: UnitModel(code: "ok")),
        VanSaleDetailModel(
            vanSaleDetails: [
              VanSaleDetail(productId: "C50", description: "Cucumber")
            ],
            price: 2.5,
            quantity: 5,
            amount: 12.5,
            updatedUnit: UnitModel(code: "sss")),
        VanSaleDetailModel(
            vanSaleDetails: [
              VanSaleDetail(productId: "T4", description: "tomato")
            ],
            price: 2.5,
            quantity: 5,
            amount: 12.5,
            updatedUnit: UnitModel(code: "ok"))
      ];

      double tax = 2.0;
      List<int> bytes = await getTicket(PrintHelper(
          vanName: "Demo dynamic",
          address: "addresses",
          phone: "9876543210",
          total: "",
          amountInWords: "",
          customer: "name",
          discount: "",
          footerImage: "",
          headerImage: "",
          invoiceNo: "",
          mobile: "9842222",
          paymentMode: "Cash",
          salesPerson: "person",
          refNo: "",
          tax: "$tax",
          subTotal: "",
          transactionDate: DateTime.now().toIso8601String(),
          trn: "",
          items: list));
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<void> printGraphics() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getGraphicsTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<List<int>> getGraphicsTicket() async {
    List<int> bytes = [];

    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    // Print QR Code using native function
    bytes += generator.qrcode('example.com');

    bytes += generator.hr();

    // Print Barcode using native function
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    bytes += generator.cut();

    return bytes;
  }

  Future<List<int>> getTicket(PrintHelper print) async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    bytes += generator.text(
      "Date: ${print.transactionDate}",
      styles: PosStyles(
        align: PosAlign.left,
      ),
    );

    bytes += generator.text("Sales Person: ${print.salesPerson ?? ""}",
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('Van Name: ${print.vanName}',
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.text("TAX INVOICE",
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          underline: true,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);
    bytes += generator.text("TRN #TRN : ${print.trn}",
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.hr(linesAfter: 1);
    bytes += generator.text(
      "Customer: ${print.customer}",
      styles: PosStyles(
        align: PosAlign.left,
      ),
    );
    bytes += generator.row([
      PosColumn(
          width: 6,
          text: "Address: ${print.address ?? ""}",
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          width: 6,
          text: "Date: ${print.transactionDate ?? ""}",
          styles: PosStyles(
            align: PosAlign.left,
          ))
    ]);
    bytes += generator.text(
      "Invoice#: ${print.invoiceNo}",
      styles: PosStyles(
        align: PosAlign.left,
      ),
    );
    bytes += generator.row([
      PosColumn(
          width: 6,
          text: "Phone: ${print.phone ?? ""}",
          styles: PosStyles(align: PosAlign.left)),
      PosColumn(
          width: 6,
          text: "SalesMan: ${print.salesPerson ?? ""}",
          styles: PosStyles(align: PosAlign.left))
    ]);
    bytes += generator.row([
      PosColumn(
          width: 6,
          text: "TRN: ${print.trn ?? ""}",
          styles: PosStyles(align: PosAlign.left)),
      PosColumn(
          width: 6, text: "Mobile:", styles: PosStyles(align: PosAlign.left))
    ]);

    bytes += generator.row([
      PosColumn(
          width: 6,
          text: "Payment Mode: ${print.paymentMode ?? ""}",
          styles: PosStyles(align: PosAlign.left)),
      PosColumn(
          width: 6,
          text: "Reference No:",
          styles: PosStyles(align: PosAlign.left))
    ]);

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
          text: '#',
          width: 1,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Name',
          width: 4,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Qty',
          width: 1,
          styles: PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'Unit',
          width: 2,
          styles: PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'Unit Price',
          width: 2,
          styles: PosStyles(align: PosAlign.right, bold: true)),
      PosColumn(
          text: 'Amount',
          width: 2,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);
    int index = 1;
    for (var rowData in print.items ?? []) {
      final maxWidth = 14; // Adjust to your desired width

      final textChunks = splitText(
          "${rowData.vanSaleDetails![0].productId} ${rowData.vanSaleDetails![0].description}",
          maxWidth);
      log(textChunks.join('\n').toString());
      bytes += await generator.row([
        PosColumn(text: "${index}", width: 1),
        PosColumn(
            text: textChunks.join('\n'),
            width: 4,
            styles: PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: "${rowData.quantity}",
            width: 1,
            styles: PosStyles(
              align: PosAlign.center,
            )),
        PosColumn(
            text: "${rowData.updatedUnit!.code}",
            width: 2,
            styles: PosStyles(align: PosAlign.center)),
        PosColumn(
            text: "${rowData.price}",
            width: 2,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: "${rowData.amount}",
            width: 2,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      index++;
    }

    bytes += generator.hr();

    bytes += generator.text("Total quantity:  21",
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    bytes += generator.hr(ch: '=', linesAfter: 1);
    bytes += generator.row([
      PosColumn(
          text: ' Amount in words:',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "",
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Sub Total:',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: print.subTotal ?? "",
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Discount:',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: print.discount ?? "",
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'VAT(0%):',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: print.tax ?? "",
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row(
      [
        PosColumn(
            text: 'Total:',
            width: 6,
            styles: PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: print.total ?? "",
            width: 6,
            styles: PosStyles(
              align: PosAlign.right,
            )),
      ],
    );

    bytes += generator.row(
      [
        PosColumn(
            text: "Receiver's Sign",
            width: 6,
            styles: PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: "Salesman's Sign",
            width: 6,
            styles: PosStyles(
              align: PosAlign.right,
            )),
      ],
    );

    // ticket.feed(2);
    // bytes += generator.text('Thank you!',
    //     styles: PosStyles(align: PosAlign.center, bold: true));

    // bytes += generator.text("26-11-2020 15:22:45",
    //     styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    // bytes += generator.text(
    //     'Note: Goods once sold will not be taken back or exchanged.',
    //     styles: PosStyles(align: PosAlign.center, bold: false));
    bytes += generator.cut();
    return bytes;
  }

  // testPrint(){
  //    final printer = BluetoothThermalPrinter.ins;
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bluetooth Thermal Printer Demo'),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Search Paired Bluetooth"),
              TextButton(
                onPressed: () {
                  this.getBluetooth();
                },
                child: Text("Search"),
              ),
              Container(
                height: 200,
                child: ListView.builder(
                  itemCount: availableBluetoothDevices.length > 0
                      ? availableBluetoothDevices.length
                      : 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        // printTicket();

                        String select = availableBluetoothDevices[index];
                        List list = select.split("#");
                        // String name = list[0];
                        String mac = list[1];
                        this.setConnect(mac);
                      },
                      title: Text('${availableBluetoothDevices[index]}'),
                      subtitle: Text("Click to connect"),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextButton(
                onPressed: connected ? this.printGraphics : null,
                child: Text("Print"),
              ),
              TextButton(
                onPressed: connected ? this.printTicket : null,
                child: Text("Print Ticket"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<int>> getTicket() async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    bytes += generator.text(
        "",
        styles: PosStyles(align: PosAlign.center),linesAfter: 1);
    bytes += generator.text(
        "Bienvenu a Guy-Kaku Montreal",
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          bold: true
        ),
    );
    bytes += generator.text(
        "(514) 866-8808\n1255 Rue Crescent,\nMontreal, QC H3G 2B1",
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
            bold: true
        ),
    );
    bytes += generator.text(
        "",
        styles: PosStyles(align: PosAlign.center),linesAfter: 1);
    bytes += generator.row([
      PosColumn(
          text: 'Server: Tida',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),),
      PosColumn(
          text: "05/05/2022",
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: '1000/1',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: "11:55 AM",
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Guests: 0',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: '',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);
    bytes += generator.text(
        "",
        styles: PosStyles(align: PosAlign.center),linesAfter: 1);
bytes += generator.row([
      PosColumn(
          text: 'Fiscal Transaction ID:',
          width: 8,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: "20220505115503",
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);
    bytes += generator.text('Order Type: Take-Out',
        styles: PosStyles(align: PosAlign.left)
    );
bytes += generator.text('Area: TakeOut',
        styles: PosStyles(align: PosAlign.left));
bytes += generator.text('Menu: HH Lunch Server',
        styles: PosStyles(align: PosAlign.left));
bytes += generator.text('Day Part: Lunch',
        styles: PosStyles(align: PosAlign.left),linesAfter: 1);
bytes += generator.text('TakeOut Order',
        styles: PosStyles(align: PosAlign.left),linesAfter: 1);
bytes += generator.row([
      PosColumn(
          text: 'Sukiyaki FriedRice w/Beef',
          width: 6,
          styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: "14.95",
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);
bytes += generator.row([
      PosColumn(
          text: 'Sukiyaki FriedRice w/Beef',
          width: 6,
          styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: "14.95",
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);
    bytes += generator.text(
        "",
        styles: PosStyles(align: PosAlign.center),linesAfter: 1);
bytes += generator.row([
      PosColumn(
          text: 'Complete Subtotal',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: "22.95",
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'TPS',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: "0.95",
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);
    bytes += generator.text(
        "",
        styles: PosStyles(align: PosAlign.center),linesAfter: 1);
    bytes += generator.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: "35\$",
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);
bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
          text: 'No',
          width: 1,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Item',
          width: 5,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Price',
          width: 2,
          styles: PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'Qty',
          width: 2,
          styles: PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'Total',
          width: 2,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);
bytes += generator.row([
      PosColumn(text: "1", width: 1),
      PosColumn(
          text: "Tea",
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "10",
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "10", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
bytes += generator.row([
      PosColumn(text: "2", width: 1),
      PosColumn(
          text: "Sada Dosa",
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "30",
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "30", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
bytes += generator.row([
      PosColumn(text: "3", width: 1),
      PosColumn(
          text: "Masala Dosa",
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "50",
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "50", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
bytes += generator.row([
      PosColumn(text: "4", width: 1),
      PosColumn(
          text: "Rova Dosa",
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "70",
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "70", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
bytes += generator.hr();
bytes += generator.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
      PosColumn(
          text: "160",
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
    ]);
bytes += generator.hr(ch: '=', linesAfter: 1);
// ticket.feed(2);
    bytes += generator.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));
bytes += generator.text("26-11-2020 15:22:45",
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);
bytes += generator.text(
        'Note: Goods once sold will not be taken back or exchanged.',
        styles: PosStyles(align: PosAlign.center, bold: false));
    bytes += generator.cut();
    return bytes;
  }

List<String> splitText(String text, int maxWidth) {
  final List<String> lines = [];
  final List<String> words = text.split(' ');
  String currentLine = '';

  for (final word in words) {
    if ((currentLine.length + word.length) <= maxWidth) {
      currentLine += '$word ';
    } else {
      lines.add(currentLine.trim());
      currentLine = '$word ';
    }
  }

  if (currentLine.isNotEmpty) {
    lines.add(currentLine.trim());
  }

  return lines;
}

class PrintHelper {
  String? transactionDate;
  String? salesPerson;
  String? vanName;
  String? customer;
  String? address;
  String? invoiceNo;
  String? phone;
  String? paymentMode;
  String? trn;
  String? mobile;
  String? refNo;
  String? amountInWords;
  String? subTotal;
  String? discount;
  String? tax;
  String? total;
  String? headerImage;
  String? footerImage;
  List<VanSaleDetailModel>? items;

  PrintHelper({
    this.transactionDate,
    this.salesPerson,
    this.vanName,
    this.customer,
    this.address,
    this.invoiceNo,
    this.phone,
    this.paymentMode,
    this.trn,
    this.mobile,
    this.refNo,
    this.amountInWords,
    this.subTotal,
    this.discount,
    this.tax,
    this.total,
    this.headerImage,
    this.footerImage,
    this.items,
  });

  static String convertAmountToWords(double amount) {
    final List<String> units = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine'
    ];

    final List<String> teens = [
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];

    final List<String> tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];

    final List<String> thousands = ['', 'Thousand', 'Million', 'Billion'];

    if (amount == 0) {
      return 'Zero';
    }

    int num = amount.toInt();
    String result = '';

    int thousandsIndex = 0;
    while (num > 0) {
      int chunk = num % 1000;
      if (chunk != 0) {
        String chunkResult = '';

        int hundreds = chunk ~/ 100;
        if (hundreds > 0) {
          chunkResult += '${units[hundreds]} Hundred';
        }

        int tensAndUnits = chunk % 100;
        if (tensAndUnits >= 10 && tensAndUnits <= 19) {
          if (chunkResult.isNotEmpty) {
            chunkResult += ' and ';
          }
          chunkResult += '${teens[tensAndUnits - 10]}';
        } else {
          int tensDigit = tensAndUnits ~/ 10;
          int unitsDigit = tensAndUnits % 10;
          if (chunkResult.isNotEmpty && (tensDigit > 0 || unitsDigit > 0)) {
            chunkResult += ' and ';
          }
          if (tensDigit > 0) {
            chunkResult += '${tens[tensDigit]}';
          }
          if (unitsDigit > 0) {
            chunkResult += '${units[unitsDigit]}';
          }
        }

        if (thousandsIndex > 0 && chunkResult.isNotEmpty) {
          chunkResult += ' ${thousands[thousandsIndex]}';
        }

        if (result.isNotEmpty && chunkResult.isNotEmpty) {
          result = '$chunkResult, $result';
        } else {
          result = '$chunkResult $result';
        }
      }

      num ~/= 1000;
      thousandsIndex++;
    }

    return result;
  }

  static String getTotalQuantity(var printDetail) {
    double quantity = 0.0;
    for (var element in printDetail.items!) {
      quantity += element.quantity;
    }
    return quantity.toString();
  }
}

class VanSaleDetailModel {
  List<VanSaleDetail>? vanSaleDetails;
  dynamic unitTax;
  dynamic price;
  dynamic quantity;
  dynamic amount;
  UnitModel? updatedUnit;
  List<UnitModel>? unitList;
  int? isTrackLot;

  VanSaleDetailModel({
    this.vanSaleDetails,
    this.unitTax,
    this.price,
    this.quantity,
    this.amount,
    this.updatedUnit,
    this.unitList,
    this.isTrackLot,
  });
}

class UnitModel {
  final String? code;
  final String? name;
  final String? productID;
  final String? factorType;
  final dynamic factor;
  final int? isMainUnit;

  UnitModel({
    this.code,
    this.name,
    this.productID,
    this.factorType,
    this.factor,
    this.isMainUnit,
  });
}

class VanSaleDetail {
  int? rowIndex;
  String? productId;
  dynamic quantity;
  dynamic unitPrice;
  String? locationId;
  dynamic listedPrice;
  dynamic amount;
  String? description;
  dynamic discount;
  dynamic taxAmount;
  String? taxGroupId;
  String? barcode;
  String? taxOption;
  String? unitId;
  int? itemType;
  String? productCategory;
  double? saleQuantity;
  double? returnQuantity;

  VanSaleDetail({
    this.rowIndex,
    this.productId,
    this.quantity,
    this.unitPrice,
    this.locationId,
    this.listedPrice,
    this.amount,
    this.description,
    this.discount,
    this.taxAmount,
    this.taxGroupId,
    this.barcode,
    this.taxOption,
    this.unitId,
    this.itemType,
    this.productCategory,
    this.saleQuantity,
    this.returnQuantity,
  });
}
