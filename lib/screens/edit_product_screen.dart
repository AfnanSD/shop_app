import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});
  static const routeName = '/edit-screen';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNose = FocusNode();
  final _imageController = TextEditingController();
  final _imageFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  // ignore: prefer_final_fields
  var _editedProduct =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');
  var _gotID = false;
  var _intitValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageURL': '',
  };
  var _isLoading = false;

  @override
  void initState() {
    _imageFocusNode.addListener(_updateImage);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_gotID) {
      final productId = ModalRoute.of(context)!.settings.arguments;
      if (productId != null) {
        _editedProduct = Provider.of<ProductsProvider>(context)
            .findById(productId as String);
        _intitValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageURL': '',
        };
        _imageController.text = _editedProduct.imageUrl;
      }
    }
    _gotID = true;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _descriptionFocusNose.dispose();
    _priceFocusNode.dispose();
    _imageController.dispose();
    _imageFocusNode.dispose();
    _imageFocusNode.removeListener(_updateImage);
    super.dispose();
  }

  void _updateImage() {
    if (!_imageFocusNode.hasFocus) {
      if (_imageController.text.isNotEmpty &&
          !_imageController.text.startsWith('http') &&
          !_imageController.text.startsWith('https')) {
        return;
      }
      setState(() {});
    }
  }

  void _saveForm() async {
    final isValidated = _form.currentState!.validate();
    if (isValidated) {
      _form.currentState?.save();
      setState(() {
        _isLoading = true;
      });
      if (_editedProduct.id.isNotEmpty) {
        await Provider.of<ProductsProvider>(context, listen: false)
            .editProduct(_editedProduct.id, _editedProduct);
        setState(() {
          _isLoading = false;
        });
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      } else {
        Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct)
            .catchError((error) {
          // ignore: prefer_void_to_null
          return showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Error!'),
              content: const Text(
                  'Something wenr wrong, \nDont\'t worry we are trying to fix it :)'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('ok'))
              ],
            ),
          );
        }).then((value) {
          Navigator.of(context).pop();
          setState(() {
            _isLoading = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit product'),
      ),
      body: Form(
        key: _form,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _intitValues['title'],
                      decoration: const InputDecoration(label: Text('Title')),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_priceFocusNode),
                      onSaved: (newValue) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: newValue!,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _intitValues['price'],
                      decoration: const InputDecoration(label: Text('Price')),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(_descriptionFocusNose),
                      onSaved: (newValue) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: double.parse(newValue!),
                            imageUrl: _editedProduct.imageUrl);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'This field is required';
                        } else if (double.tryParse(value) == null) {
                          return 'This value mus be a number';
                        } else if (double.parse(value) <= 0) {
                          return 'This value must be greater than 0';
                        } else {
                          return null;
                        }
                      },
                    ),
                    TextFormField(
                      initialValue: _intitValues['description'],
                      decoration:
                          const InputDecoration(label: Text('Description')),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNose,
                      onSaved: (newValue) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: _editedProduct.title,
                            description: newValue!,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'This field is required';
                        } else {
                          return null;
                        }
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          //padding: const EdgeInsets.only(top: 8, right: 16),
                          margin: const EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: _imageController.text.isEmpty
                              ? const Text('Enter image URL')
                              : FittedBox(
                                  fit: BoxFit.fill,
                                  child: Image.network(_imageController.text),
                                ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                label: Text('Image URL'),
                              ),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageController,
                              onEditingComplete: () => setState(() {}),
                              focusNode: _imageFocusNode,
                              onFieldSubmitted: (value) => _saveForm(),
                              onSaved: (newValue) {
                                _editedProduct = Product(
                                    id: _editedProduct.id,
                                    isFavorite: _editedProduct.isFavorite,
                                    title: _editedProduct.title,
                                    description: _editedProduct.description,
                                    price: _editedProduct.price,
                                    imageUrl: newValue!);
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'This field is required';
                                }
                                // else if (!value.startsWith('http') &&
                                //     !value.startsWith('https')) {
                                //   return 'Enter a valid URL';
                                //}
                                else {
                                  return null;
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {});
                          _saveForm();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.save),
                            SizedBox(width: 20),
                            Text('Save'),
                          ],
                        ))
                  ],
                ),
              ),
      ),
    );
  }
}
