import 'package:ecommerce_int2/app_properties.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:ecommerce_int2/models/globals.dart' as global;
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:ecommerce_int2/models/province.dart';
import 'package:ecommerce_int2/models/city.dart';
import 'package:ecommerce_int2/models/courier.dart';

class AddAddressForm extends StatefulWidget {
  @override
  _AddAddressForm createState() => _AddAddressForm();
}

class _AddAddressForm extends State<AddAddressForm> {
  List<String> genders = <String>['Pilih', 'L', 'P'];
  String dropdownValue = '';

  List<Province> provinces = [];
  List<Province> label_provinces = [];
  String dropdownProvinceValue = '';

  List<City> cities = [];
  List<City> label_cities = [];
  String dropdownCityValue = '';

  List<Courier> courieres = [];
  List<Courier> label_courieres = [];
  String dropdownCourierValue = '';

  List<String> shipcostes = <String>[''];
  List<String> label_shipcostes = <String>[''];
  String dropdownShipcostValue = '';

  List<String> bankes = <String>[''];
  List<String> label_bankes = <String>[''];
  String dropdownBankValue = '';

  var isLoadingData = false;
  var isLoadingCityData = false;

  TextEditingController nameController = TextEditingController(text: '');
  TextEditingController phoneController = TextEditingController(text: '');
  TextEditingController genderController = TextEditingController(text: '');
  TextEditingController provinceController = TextEditingController(text: '');
  TextEditingController cityController = TextEditingController(text: '');
  TextEditingController addressController = TextEditingController(text: '');
  TextEditingController postCodeController = TextEditingController(text: '');
  TextEditingController courierController = TextEditingController(text: '');
  TextEditingController shipCostController = TextEditingController(text: '');
  TextEditingController bankCostController = TextEditingController(text: '');


  void showToast(String msg, {int? duration, int? gravity}) {
    ToastContext().init(context);
    Toast.show(msg, duration: duration, gravity: gravity);
  }


  @override
  Future<void> getProvince() async {
    isLoadingData = true;
    provinces = [];
    label_provinces.clear();

    final response = await http.post(
      Uri.parse(global.appUrl + "/alamat.php"),
      body: {
        'param': 'getProvince'
      },
      headers: {
        'Authorization': global.bearerToken
      },
    );

    var result = jsonDecode(response.body.toString());

    // return print(result);

    if (response.statusCode == 201) {
      result['data'].forEach((key, value) {
        if (provinces.contains(key) == false) {
          Province myProvince = Province(key.toString(), value.toString());
          provinces.add(myProvince);
        }
      });

      isLoadingData = false;
    } else if (response.statusCode == 401) {
      return showToast(result['message'], gravity: Toast.bottom);
    } else {
      return showToast("Gagal", gravity: Toast.bottom);
    }
  }


  @override
  Future<void> getCity(String id) async {
    isLoadingCityData = true;
    label_provinces.clear();
    cities.clear();

    final response = await http.post(
      Uri.parse(global.appUrl + "/alamat.php"),
      body: {
        'param': 'getCity',
        'id_provinces' : id
      },
      headers: {
        'Authorization': global.bearerToken
      },
    );

    var result = jsonDecode(response.body.toString());
    print(result);

    if (response.statusCode == 201) {
      result['data'].forEach((key, value) {
          City myCities = City(key.toString(), value.toString());
          cities.add(myCities);
      });

      isLoadingCityData = false;
    } else if (response.statusCode == 401) {
      return showToast(result['message'], gravity: Toast.bottom);
    } else {
      return showToast("Gagal", gravity: Toast.bottom);
    }
  }

  @override
  Future<void> getCourier() async {
    isLoadingData = true;
    courieres.clear();
    label_provinces.clear();

    final response = await http.post(
      Uri.parse(global.appUrl + "/kurir.php"),
      headers: {
        'Authorization': global.bearerToken
      },
    );

    var result = jsonDecode(response.body.toString());

    if (response.statusCode == 201) {
      result['data'].forEach((key, value) {
          Courier myCourieres = Courier(key.toString(), value.toString());
          courieres.add(myCourieres);
      });

      isLoadingData = false;
    } else if (response.statusCode == 401) {
      return showToast(result['message'], gravity: Toast.bottom);
    } else {
      return showToast("Gagal", gravity: Toast.bottom);
    }
  }

  @override
  void initState() {
    super.initState();
    getProvince();
    // getCourier();
  }

  Widget build(BuildContext context) {
    return SizedBox(
        height: 1000,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            // crossAxisAlignment: CrossAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
              padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: Colors.white,
              ),
              child: DropdownMenu<String>(
                    enableSearch: true,
                    width: MediaQuery.of(context).size.width/1.2,
                    initialSelection: genderController.text,
                    label: Text("Jenis Kelamin"),
                    inputDecorationTheme: const InputDecorationTheme(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                    ),
                    onSelected: (String? value) {
                      // This is called when the user selects an item.
                      genderController.text = value.toString();
                    },
                    dropdownMenuEntries: genders.map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry<String>(value: value, label: value);
                    }).toList(),
                  )
              ),
              Container(
                  padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.white,
                  ),
                  child: FutureBuilder(
                      future: Future.delayed(Duration.zero, () => getProvince()),
                      builder: (context, snapshot) {

                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return Text('none');
                          case ConnectionState.waiting:
                            return DefaultTextStyle(
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .displayMedium!,
                                textAlign: TextAlign.center,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      CircularProgressIndicator(
                                        semanticsLabel: 'Circular progress indicator',
                                      ),
                                    ]
                                )
                            );
                          case ConnectionState.active:
                            return Text('');
                          case ConnectionState.done:
                            if (snapshot.hasError) {
                              return Text(
                                '${snapshot.error}',
                                style: TextStyle(color: Colors.red),
                              );
                            } else {
                              return DropdownButton<String>(
                                hint: const Text("Provinsi"),
                                elevation: 16,
                                onChanged:  (String? value) {
                                  // This is called when the user selects an item.
                                  provinceController.text = value.toString();
                                  getCity(provinceController.text);
                                },
                                items: provinces.map<DropdownMenuItem<String>>((Province value) {
                                  return DropdownMenuItem<String>(value: value.id, child: Text(value.name) );
                                }).toList(),
                              );
                            }
                        }

                  })
              ),
          ]
        ),
    );

    return FutureBuilder(
        future: Future.delayed(Duration.zero, () => getProvince()),
        builder: (context, snapshot) {

          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('none');
            case ConnectionState.waiting:
                return DefaultTextStyle(
                    style: Theme
                        .of(context)
                        .textTheme
                        .displayMedium!,
                    textAlign: TextAlign.center,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          CircularProgressIndicator(
                            semanticsLabel: 'Circular progress indicator',
                          ),
                        ]
                    )
                );
            case ConnectionState.active:
              return Text('');
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text(
                  '${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                );
              } else {

                return SizedBox(
                  height: 1000,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.white,
                        ),
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                              label: Text('Nama Lengkap'),
                              border: InputBorder.none
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.white,
                        ),
                        child: TextField(
                          controller: phoneController,
                          decoration:
                          InputDecoration(label: Text('No WA/Telp'),border: InputBorder.none),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.white,
                        ),
                        child: DropdownMenu<String>(
                          enableSearch: true,
                          width: MediaQuery.of(context).size.width/1.2,
                          initialSelection: genderController.text,
                          label: Text("Jenis Kelamin"),
                          inputDecorationTheme: const InputDecorationTheme(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                          ),
                          onSelected: (String? value) {
                            // This is called when the user selects an item.
                            genderController.text = value.toString();
                          },
                          dropdownMenuEntries: genders.map<DropdownMenuEntry<String>>((String value) {
                            return DropdownMenuEntry<String>(value: value, label: value);
                          }).toList(),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Alamat Pengiriman',
                              style: TextStyle(fontSize: 12, color: darkGrey),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.white,
                        ),
                        child: DropdownMenu<String>(
                          enableSearch: false,
                          width: MediaQuery.of(context).size.width/1.2,
                          initialSelection: provinceController.text,
                          label: Text("Provinsi"),
                          inputDecorationTheme: const InputDecorationTheme(
                            border: InputBorder.none,
                            isDense: false,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                          ),
                          onSelected: (String? value) {
                            // This is called when the user selects an item.
                            provinceController.text = value.toString();
                            getCity(provinceController.text);
                          },
                          dropdownMenuEntries: provinces.map<DropdownMenuEntry<String>>((Province value) {
                            return DropdownMenuEntry<String>(value: value.id, label: value.name);
                          }).toList(),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.white,
                        ),
                        child: (isLoadingCityData)? DefaultTextStyle(
                            style: Theme
                                .of(context)
                                .textTheme
                                .displayMedium!,
                            textAlign: TextAlign.center,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[ Padding(
                                  padding: EdgeInsets.fromLTRB(10,10,10,10),
                                  child: SizedBox(
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        semanticsLabel: 'Circular progress indicator',
                                      ),
                                    ),
                                    height: 20.0,
                                    width: 20.0,
                                  ),
                                )]
                            )
                        ) :DropdownMenu<String>(
                          enableSearch: false,
                          width: MediaQuery.of(context).size.width/1.2,
                          initialSelection: '',
                          label: Text("Kota/Kabupaten"),
                          inputDecorationTheme: const InputDecorationTheme(
                            border: InputBorder.none,
                            isDense: false,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                          ),
                          onSelected: (String? value) {
                            // This is called when the user selects an item.
                            cityController.text = value.toString();
                          },
                          dropdownMenuEntries: cities.map<DropdownMenuEntry<String>>((City value) {
                            return DropdownMenuEntry<String>(value: value.id, label: value.name);
                          }).toList(),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.white,
                        ),
                        child: TextField(
                          decoration:
                          InputDecoration(label: Text('Alamat Kecamatan, Desa, RT/RW, Jalan'),border: InputBorder.none),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.white,
                        ),
                        child: TextField(
                          decoration:
                          InputDecoration(label: Text('Kode POS'),border: InputBorder.none),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Pengiriman',
                              style: TextStyle(fontSize: 12, color: darkGrey),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.white,
                        ),
                        child: DropdownMenu<String>(
                          enableSearch: false,
                          width: MediaQuery.of(context).size.width/1.2,
                          initialSelection: courierController.text,
                          label: Text("Kurir"),
                          inputDecorationTheme: const InputDecorationTheme(
                            border: InputBorder.none,
                            isDense: false,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                          ),
                          onSelected: (String? value) {
                            // This is called when the user selects an item.
                            courierController.text = value.toString();
                          },
                          dropdownMenuEntries: courieres.map<DropdownMenuEntry<String>>((Courier value) {
                            // print(value.name);
                            return DropdownMenuEntry<String>(value: value.id, label: value.name);
                          }).toList(),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.white,
                        ),
                        child: DropdownMenu<String>(
                          enableSearch: false,
                          width: MediaQuery.of(context).size.width/1.2,
                          initialSelection: '',
                          label: Text("Ongkos Kirim"),
                          inputDecorationTheme: const InputDecorationTheme(
                            border: InputBorder.none,
                            isDense: false,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                          ),
                          onSelected: (String? value) {
                            // This is called when the user selects an item.
                            dropdownShipcostValue = value.toString();
                          },
                          dropdownMenuEntries: label_shipcostes.map<DropdownMenuEntry<String>>((String value) {
                            return DropdownMenuEntry<String>(value: value, label: value);
                          }).toList(),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.white,
                        ),
                        child: DropdownMenu<String>(
                          enableSearch: false,
                          width: MediaQuery.of(context).size.width/1.2,
                          initialSelection: '',
                          label: Text("Bank Transfer"),
                          inputDecorationTheme: const InputDecorationTheme(
                            border: InputBorder.none,
                            isDense: false,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                          ),
                          onSelected: (String? value) {
                            // This is called when the user selects an item.
                            dropdownCityValue = value.toString();
                          },
                          dropdownMenuEntries: label_bankes.map<DropdownMenuEntry<String>>(( String value) {
                            return DropdownMenuEntry<String>(value: value, label: value);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              }
          }
        }
    );
  }
}
