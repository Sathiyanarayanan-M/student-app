import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_app/admin/attendance/DbAndRefs.dart';

class UploadProfile extends StatefulWidget {
  @override
  _UploadProfile createState() => _UploadProfile();
}

class _UploadProfile extends State<UploadProfile> {
  String id,
      name,
      rollNo,
      regNo,
      email,
      phoneNo,
      blood,
      batch,
      dept,
      address,
      dob;
  File _image;
  String cls;

  String profileUrl;
  final picker = ImagePicker();
  final reference = FirebaseFirestore.instance;
  String dep, yer;
  List<Contents> year = List();
  List<Contents> department = List();
  List<Contents> classes = List();

  DbRef obj = DbRef();

  @override
  void initState() {
    super.initState();
    CollectionReference yearRef = obj.getDetailRef('year');
    CollectionReference depRef = obj.getDetailRef('department');
    yearRef.snapshots().listen((event) {
      setState(() {
        for (int i = 0; i < event.docs.length; i++) {
          year.add(Contents.fromSnapshot(event.docs[i]));
        }
      });
    });
    depRef.snapshots().listen((event) {
      if (mounted) {
        setState(() {
          for (int i = 0; i < event.docs.length; i++) {
            department.add(Contents.fromSnapshot(event.docs[i]));
          }
        });
      }
    });
  }

  Future getImage() async {
    try {
      var image = await picker.getImage(source: ImageSource.gallery);

      setState(() {
        _image = File(image.path);
      });
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text("No image selected. Please select a image."),
      ));
    }
  }

  Future upload(BuildContext context) async {
    if (formKey.currentState.validate()) {
      try {
        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('profile/$batch/$dept/$regNo');
        UploadTask uploadTask = firebaseStorageRef.putFile(_image);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        var url = await taskSnapshot.ref.getDownloadURL();
        profileUrl = url.toString();

        DocumentReference ref = FirebaseFirestore.instance
            .collection('collage')
            .doc('student')
            .collection('$dept')
            .doc('$batch')
            .collection('$cls')
            .doc('$regNo');
        ref.set({
          'Name': '$name',
          'Rollno': '$rollNo',
          'Regno': '$regNo',
          'Email': '$email',
          'PhoneNo': '$phoneNo',
          'BloodGroup': '$blood',
          'Batch': '$batch',
          'Department': '$dept',
          'Address': '$address',
          'ProfileUrl': '$profileUrl',
          'DOB': '$dob',
          'Class': '$cls'
        });

        Scaffold.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 1),
          content: Text('Profile Picture Uploaded'),
        ));

        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Submitted Successfully'),
        ));
        formKey.currentState.reset();
        setState(() {
          _image = null;
        });
      } catch (e) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Select a profile picture'),
        ));
      }
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Invalid Details'),
      ));
    }
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Widget buildNameField() {
    return TextFormField(
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(5.0),
            ),
          ),
          labelText: 'Name',
          hintText: 'Ex: Ramesh M',
          contentPadding: EdgeInsets.all(15.0),
          filled: true,
          fillColor: Colors.white54),
      maxLength: 20,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Name required';
        }
        return null;
      },
      onSaved: (String value) {
        name = value;
      },
    );
  }

  Widget buildRollNoField() {
    return TextFormField(
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(5.0),
            ),
          ),
          labelText: 'Roll Number',
          hintText: 'Ex: B16cs058',
          contentPadding: EdgeInsets.all(15.0),
          filled: true,
          fillColor: Colors.white54),
      maxLength: 8,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Roll Number Required';
        }
        return null;
      },
      onSaved: (String value) {
        rollNo = value;
      },
    );
  }

  Widget buildRegNoField() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(5.0),
            ),
          ),
          labelText: 'Register Number',
          hintText: 'Ex: 820617104035',
          contentPadding: EdgeInsets.all(15.0),
          filled: true,
          fillColor: Colors.white54),
      maxLength: 12,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Register Number Required';
        }
        return null;
      },
      onSaved: (String value) {
        regNo = value;
      },
    );
  }

  Widget buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(5.0),
            ),
          ),
          labelText: 'Email',
          hintText: 'Ex: example@gmail.com',
          contentPadding: EdgeInsets.all(15.0),
          filled: true,
          fillColor: Colors.white54),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Email Required';
        }
        if (!RegExp(
                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(value)) {
          return 'Valid Email Required';
        }
        return null;
      },
      onSaved: (String value) {
        email = value;
      },
    );
  }

  Widget buildPhoneField() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(5.0),
            ),
          ),
          labelText: 'Phone Number',
          hintText: 'Ex: 9849342931',
          contentPadding: EdgeInsets.all(15.0),
          filled: true,
          fillColor: Colors.white54),
      maxLength: 10,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Phone Number Required';
        }
        return null;
      },
      onSaved: (String value) {
        phoneNo = value;
      },
    );
  }

  Widget buildBloodGroupField() {
    return TextFormField(
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(5.0),
            ),
          ),
          labelText: 'Blood Group',
          hintText: 'Ex: O Positive',
          contentPadding: EdgeInsets.all(15.0),
          filled: true,
          fillColor: Colors.white54),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Blood Group Required';
        }
        return null;
      },
      onSaved: (String value) {
        blood = value.toUpperCase();
      },
    );
  }

  Widget buildBatchDropDown() {
    return DropdownButton(
      hint: Text('select year'),
      onChanged: (String name) {
        setState(() {
          batch = name;
        });
      },
      value: batch,
      items: year
          .map((e) => DropdownMenuItem(
                child: Text(e.name),
                value: e.name,
              ))
          .toList(),
    );
  }

  Widget buildDeptDropDown() {
    return DropdownButton(
      hint: Text('select department'),
      onChanged: (name) {
        setState(() {
          dept = name;
        });
      },
      value: dept,
      items: department
          .map((e) => DropdownMenuItem(
                child: Text(e.name),
                value: e.name,
              ))
          .toList(),
    );
  }

  Widget buildAddressField() {
    return TextFormField(
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(5.0),
            ),
          ),
          labelText: 'Address',
          hintText: 'Ex: 23,Dubai kuruku santhu, dubai',
          contentPadding: EdgeInsets.all(15.0),
          filled: true,
          fillColor: Colors.white54),
      maxLines: 8,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Address Required';
        }
        return null;
      },
      onSaved: (String value) {
        address = value;
      },
    );
  }

  Widget buildDOBField() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(5.0),
            ),
          ),
          labelText: 'DOB',
          hintText: 'EX: 30-12-1999',
          contentPadding: EdgeInsets.all(15.0),
          filled: true,
          fillColor: Colors.white54),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Address Required';
        }
        return null;
      },
      onSaved: (String value) {
        dob = value.toString();
      },
    );
  }

  initiateClass() {
    CollectionReference reference;
    reference = obj.getDetailRef2(batch, dept);
    reference.snapshots().listen((event) {
      classes.clear();
      setState(() {
        for (int i = 0; i < event.docs.length; i++) {
          classes.add(Contents.fromSnapshot(event.docs[i]));
        }
      });
    });
  }

  Widget retrieveClasses(batch, dept) {
    initiateClass();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: Text(
            'CLASS',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          child: DropdownButton(
            hint: Text('select class'),
            onChanged: (name) {
              setState(() {
                cls = name;
              });
            },
            value: cls,
            items: classes
                .map((e) => DropdownMenuItem(
                      child: Text(e.name),
                      value: e.name,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget uploadProfilePic() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: InkWell(
            onTap: () {
              getImage();
            },
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Color(0xff476cfb),
              child: ClipOval(
                child: SizedBox(
                  width: 137.0,
                  height: 137.0,
                  child: (_image != null)
                      ? Image.file(
                          _image,
                          fit: BoxFit.fill,
                        )
                      : Image.asset(
                          'assets/noimage.png',
                          fit: BoxFit.fill,
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            margin: EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  uploadProfilePic(),
                  SizedBox(height: 10),
                  buildNameField(),
                  SizedBox(height: 10),
                  buildRollNoField(),
                  SizedBox(height: 10),
                  buildRegNoField(),
                  SizedBox(height: 10),
                  buildPhoneField(),
                  SizedBox(height: 10),
                  buildDOBField(),
                  SizedBox(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Text(
                            'BATCH',
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        buildBatchDropDown()
                      ]),
                  SizedBox(height: 10),
                  buildEmailField(),
                  SizedBox(height: 10),
                  buildBloodGroupField(),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Text(
                          'DEPARTMENT',
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(child: buildDeptDropDown()),
                    ],
                  ),
                  (dept != null && batch != null)
                      ? retrieveClasses(batch, dept)
                      : Container(),
                  SizedBox(height: 10),
                  buildAddressField(),
                  SizedBox(height: 10),
                  OutlineButton(
                    splashColor: Colors.blue,
                    child: Text('Submit',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                        )),
                    onPressed: () {
                      formKey.currentState.save();
                      upload(context);
                    }, //onPressed
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
