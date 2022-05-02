// ignore_for_file: prefer_final_fields

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sys_ivy_frontend/entity/product_entity.dart';

import '../config/firestore_config.dart';
import '../entity/category_entity.dart';
import '../utils/toasts.dart';

class ProductAddEditScreen extends StatefulWidget {
  final Object? args;

  const ProductAddEditScreen(this.args, {Key? key}) : super(key: key);

  @override
  State<ProductAddEditScreen> createState() => _ProductAddEditScreenState();
}

class _ProductAddEditScreenState extends State<ProductAddEditScreen> {
  // ----------------------------------------------------------
  // VARIABLES
  // ----------------------------------------------------------
  TextEditingController _id = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _description = TextEditingController();

  List<Uint8List> _images = [];
  List<CategoryEntity> _listCategory = [];
  CategoryEntity? _categoryDropdownValue;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  Object? _args;

  // ----------------------------------------------------------
  // METHODS
  // ----------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _args = widget.args;

    _cleanForm();
    _fillCategories();
    _recoverProduct();
  }

  void _fillCategories() async {
    CollectionReference catRef =
        _firestore.collection(DaoConfig.CATEGORY_COLLECTION);
    QuerySnapshot? snapshot = await catRef.get();

    if (snapshot.docs.isNotEmpty) {
      for (DocumentSnapshot item in snapshot.docs) {
        setState(() {
          _listCategory.add(CategoryEntity.fromDocument(item));
        });
      }
    }
  }

  void _cleanForm() {
    _id.text = '';
    _name.text = '';
    _description.text = '';
    _images = [];
  }

  void _recoverProduct() async {
    if (_args != null && _args.toString().isNotEmpty) {
      DocumentSnapshot snapshot = await _firestore
          .collection(DaoConfig.PRODUCT_COLLECTION)
          .doc(_args.toString())
          .get();

      if (snapshot.exists) {
        ProductEntity ce = ProductEntity.fromDocument(snapshot);
        setState(() {
          _id.text = ce.idProduct!.toString();
          _description.text = ce.description == null ? '' : ce.description!;
          _name.text = ce.name!;
          _categoryDropdownValue = ce.category;
          _getImages(ce.images);
        });
      }
    }
  }

  void _getImages(List<String> images) {
    if (images.isEmpty) {
      _images = [];
    }

    for (var imageUrl in images) {
      _storage.refFromURL(imageUrl).getData(10485760).then((data) {
        setState(() {
          if (data != null) {
            _images.add(data);
          }
        });
      });
    }
  }

  double _boxWidth(double _screenWidth) {
    double loginBoxWidth = _screenWidth;

    if (_screenWidth > 750) {
      loginBoxWidth = 650;
    }

    return loginBoxWidth;
  }

  void _validForm() async {
    if (_name.text.isEmpty) {
      showWarningToast(context, "Nome é um campo obrigatório!");
      return;
    }

    if (_categoryDropdownValue == null) {
      showWarningToast(context, "Categoria é um campo obrigatório!");
      return;
    }

    if (_description.text.isEmpty) {
      showWarningToast(context, "Descrição é um campo obrigatório!");
      return;
    }

    // Valid if exists another product with the same name
    CollectionReference catRef =
        _firestore.collection(DaoConfig.PRODUCT_COLLECTION);

    QuerySnapshot? snapshot = await catRef.get();

    List<ProductEntity> list = [];
    if (snapshot.docs.isNotEmpty) {
      for (DocumentSnapshot item in snapshot.docs) {
        ProductEntity temp = ProductEntity.fromDocument(item);
        list.add(temp);

        if (temp.name!
            .toLowerCase()
            .trim()
            .contains(_name.text.trim().toLowerCase())) {
          if (_id.text.isEmpty ||
              _id.text.compareTo(temp.idProduct.toString()) != 0) {
            showWarningToast(context,
                "Já existe um produto com este nome. ID: ${temp.idProduct}");
            return;
          }
        }
      }
    }

    _saveOrUpdate();
  }

  void _saveOrUpdate() {
    // TODO -
    // Save the images first, get the id and save the product
  }

  void _selectImage() async {
    // image
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    // recover the bytes
    setState(() {
      Uint8List? bytes = result?.files.single.bytes;

      if (bytes != null) {
        _images.add(bytes);
      }
    });
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SizedBox(
        width: _boxWidth(_screenWidth),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _id,
                      keyboardType: TextInputType.text,
                      enabled: false,
                      decoration: const InputDecoration(
                        hintText: "",
                        labelText: "ID Produto",
                        suffixIcon: Icon(Icons.star_border_rounded),
                      ),
                    ),
                    TextField(
                      controller: _name,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: "",
                        labelText: "Nome / Título",
                        suffixIcon: Icon(Icons.text_fields_rounded),
                      ),
                    ),
                    TextField(
                      controller: _description,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "",
                        labelText: "Descrição",
                        suffixIcon: Icon(Icons.text_fields_rounded),
                      ),
                    ),
                    DropdownButton(
                      isExpanded: true,
                      hint: const Text("Categoria"),
                      borderRadius: BorderRadius.circular(10),
                      value: _categoryDropdownValue,
                      items: List<DropdownMenuItem<CategoryEntity>>.generate(
                        _listCategory.length,
                        (index) => DropdownMenuItem<CategoryEntity>(
                          value: _listCategory[index],
                          child: Text(_listCategory[index].description!),
                        ),
                      ),
                      onChanged: (CategoryEntity? category) {
                        setState(() {
                          _categoryDropdownValue = category;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: _selectImage,
              child: SizedBox(
                width: _boxWidth(_screenWidth) / 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Text(
                      "Adicionar imagem",
                      softWrap: true,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.add_a_photo_rounded,
                      size: 80,
                    ),
                  ],
                ),
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
              ),
            ),
            Visibility(
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Image.memory(
                        _images[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ],
              ),
              visible: _images.isNotEmpty,
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _cleanForm();
                    });
                  },
                  style: ButtonStyle(
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text("Limpar"),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.cleaning_services_rounded,
                        size: 15,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _validForm();
                    });
                  },
                  style: ButtonStyle(
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text("Salvar"),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.save_alt_rounded,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
