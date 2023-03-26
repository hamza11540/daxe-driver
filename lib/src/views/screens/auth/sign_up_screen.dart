import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:taker_driver/src/models/vehicle_type.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:validators/validators.dart';

import '../../../controllers/user_controller.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/images.dart';
import '../../../helper/styles.dart';
import '../../../models/driver.dart';
import '../../../models/user.dart';
import '../../../repositories/setting_repository.dart';
import '../../../repositories/user_repository.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/image_picker.dart';
import '../legal_terms.dart';
import '../privacy_policy.dart';

class SignupScreen extends StatefulWidget {
  bool edit;
  SignupScreen({Key? key, this.edit = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SignupScreenState();
  }
}

class SignupScreenState extends StateMVC<SignupScreen> {
  int lastPage = 0;
  List<String> errors = [];
  late UserController _userCon;
  bool loading = false;
  User user = User(driver: Driver());
  late FToast fToast;
  DateTime now = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _brandFocus = FocusNode();
  final FocusNode _modelFocus = FocusNode();
  final FocusNode _plateFocus = FocusNode();
  final FocusNode _vehicleDocumentFocus = FocusNode();

  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  bool vehicleTypeError = false;

  File? driverLicense;
  bool driverLicenseError = false;

  SignupScreenState() : super(UserController()) {
    _userCon = controller as UserController;
  }

  @override
  void initState() {
    if (widget.edit) {
      setState(() => user = currentUser.value);
    }
    fToast = FToast();
    fToast.init(context);
    super.initState();
  }

  Future<void> showQuitRegisterDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.wantToLeaveRegistration),
        content:
            Text(AppLocalizations.of(context)!.exitingRegistrationDataLost),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.leave),
            isDefaultAction: true,
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> submitForm() async {
    setState(() {
      errors = [];
      loading = true;
    });
    if (widget.edit) {
      await _userCon.doUpdateRegister(user, driverLicense).then((value) {
        setState(() => loading = false);
        fToast.removeCustomToast();
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).popAndPushNamed('/Splash');
        fToast.showToast(
          child: CustomToast(
            backgroundColor: Colors.green,
            icon: Icon(Icons.check, color: Colors.white),
            text: AppLocalizations.of(context)!.registerUpdatedSuccessfully,
            textColor: Colors.white,
          ),
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 3),
        );
      }).catchError((error) {
        fToast.removeCustomToast();
        print(error.toString());
        setState(() => loading = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.page != lastPage) {
            _pageController.jumpToPage(lastPage);
          }
        });
        String errorMessage = AppLocalizations.of(context)!.errorUpdatingRegistrationTryAgain;
        try {
          if (error.message is Map) {
            error.message.forEach((index, value) {
              errors.add(value[0]);
            });
            errorMessage = AppLocalizations.of(context)!.fixErrorFieldsTryAgain;
            setState(() => errors);
          }
        } catch (e) {}
        fToast.showToast(
          child: CustomToast(
            backgroundColor: Colors.red,
            icon: Icon(Icons.close, color: Colors.white),
            text: errorMessage,
            textColor: Colors.white,
          ),
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 3),
        );
      });
    } else {
      await _userCon.doRegister(user, driverLicense).then((value) {
        setState(() => loading = false);
        fToast.removeCustomToast();
        Navigator.of(context).pushReplacementNamed('/Splash');
        fToast.showToast(
          child: CustomToast(
            backgroundColor: Colors.green,
            icon: Icon(Icons.check, color: Colors.white),
            text: AppLocalizations.of(context)!.successfullyRegistered,
            textColor: Colors.white,
          ),
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 3),
        );
      }).catchError((error) {
        fToast.removeCustomToast();
        print(error.toString());
        setState(() => loading = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.page != lastPage) {
            _pageController.jumpToPage(lastPage);
          }
        });
        String errorMessage = AppLocalizations.of(context)!.errorRegisteringTryAgain;
        try {
          if (error.message is Map) {
            error.message.forEach((index, value) {
              errors.add(value[0]);
            });
            errorMessage =  AppLocalizations.of(context)!.fixErrorFieldsTryAgain;
            setState(() => errors);
          }
        } catch (e) {}
        fToast.showToast(
          child: CustomToast(
            backgroundColor: Colors.red,
            icon: Icon(Icons.close, color: Colors.white),
            text: errorMessage,
            textColor: Colors.white,
          ),
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 3),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentPage > 0) {
          _pageController.previousPage(
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        } else {
          await showQuitRegisterDialog();
        }
        return false;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () async {
                await showQuitRegisterDialog();
              },
            ),
            elevation: 0,
          ),
          body: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Center(
                    child: Image.asset(Images.logo,
                        height: MediaQuery.of(context).size.height * 0.15),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  if (errors.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      margin: EdgeInsets.symmetric(
                          horizontal: Dimensions.PADDING_SIZE_EXTRA_LARGE,
                          vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          for (String error in errors)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              child: Text(
                                error,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                        ],
                      ),
                    )
                ],
              ),
              //Campos do formulário
              loading
                  ? Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.PADDING_SIZE_EXTRA_LARGE),
                      height: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator()),
                          SizedBox(height: 30),
                          Text(
                            AppLocalizations.of(context)!.waitSavingRegistration,
                            style: kTitleStyle.copyWith(
                              fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE_2,
                              color: Theme.of(context).primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: ExpandablePageView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() => _currentPage = page);
                        },
                        children: generateFormFields(),
                      ),
                    ),

              //Botões de navegação
              if (!loading)
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, left: 10, right: 10, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _currentPage == 0
                          ? SizedBox()
                          : Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: Theme.of(context).hintColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.ease,
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: 30.0,
                                    ),
                                    SizedBox(width: 10.0),
                                    Text(
                                      AppLocalizations.of(context)!.back,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            bool nextPage = false;
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              nextPage = true;
                            }
                            if (nextPage) {
                              if (_currentPage == lastPage) {
                                await submitForm();
                              } else {
                                _pageController.nextPage(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              }
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                _currentPage == lastPage
                                    ? AppLocalizations.of(context)!.finalize
                                    : AppLocalizations.of(context)!.continuee,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Icon(
                                _currentPage == lastPage
                                    ? Icons.check
                                    : Icons.arrow_forward,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          // bottomSheet: Container(
          //   height: 70,
          //   width: double.infinity,
          //   color: Theme.of(context).colorScheme.primary,
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: <Widget>[
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.end,
          //         children: [
          //           SizedBox(width: 40.0),
          //           // Expanded(
          //           //   child: Row(
          //           //     mainAxisAlignment: MainAxisAlignment.center,
          //           //     children: _buildPageIndicator(),
          //           //   ),
          //           // ),
          //           if (_currentPage != _numPages - 1)
          //             Align(
          //               alignment: FractionalOffset.bottomRight,
          //               child: TextButton(
          //                 onPressed: () {
          //                   _pageController.nextPage(
          //                     duration: Duration(milliseconds: 500),
          //                     curve: Curves.ease,
          //                   );
          //                 },
          //                 child: Row(
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   mainAxisSize: MainAxisSize.min,
          //                   children: <Widget>[
          //                     SizedBox(width: 10.0),
          //                     Icon(
          //                       Icons.arrow_forward,
          //                       color: Colors.white,
          //                       size: 30.0,
          //                     ),
          //                     SizedBox(width: 30),
          //                   ],
          //                 ),
          //               ),
          //             ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
        ),
      ),
    );
  }

  List<Widget> generateFormFields() {
    final fields = [
      // STEP 1
      Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Padding(
            padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            child: CustomTextFormField(
              isRequired: true,
              validator: (String value) {
                if (value.isEmpty || value.length <= 3) {
                  return AppLocalizations.of(context)!.enterFullName;
                }
                return null;
              },
              onSave: (String value) {
                setState(() => user.name = value);
              },
              initialValue: user.name,
              hintText: AppLocalizations.of(context)!.fullName,
              labelText: AppLocalizations.of(context)!.fullName,
              focusNode: _fullNameFocus,
              nextFocus: _emailFocus,
              inputType: TextInputType.name,
              inputFormatters: [LengthLimitingTextInputFormatter(150)],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            child: CustomTextFormField(
              isRequired: true,
              validator: (String value) {
                if (value.isEmpty) {
                  return AppLocalizations.of(context)!.enterEmail;
                } else if (!isEmail(value)) {
                  return AppLocalizations.of(context)!.enterValidEmail;
                }
                return null;
              },
              onSave: (String value) {
                setState(() => user.email = value);
              },
              initialValue: user.email,
              inputFormatters: [LengthLimitingTextInputFormatter(191)],
              hintText: AppLocalizations.of(context)!.email,
              labelText: AppLocalizations.of(context)!.email,
              focusNode: _emailFocus,
              nextFocus: _phoneFocus,
              inputType: TextInputType.emailAddress,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            child: CustomTextFormField(
              isRequired: true,
              validator: (String value) {
                if (value.isEmpty) {
                  return AppLocalizations.of(context)!.enterPhoneCorrectly;
                } else if (value.length < 8) {
                  return AppLocalizations.of(context)!.enterFullPhoneNumber;
                }
                return null;
              },
              onSave: (String value) {
                setState(() => user.phone = value);
              },
              initialValue: user.phone,
              hintText: AppLocalizations.of(context)!.phone,
              labelText: AppLocalizations.of(context)!.phone,
              focusNode: _phoneFocus,
              nextFocus: _passwordFocus,
              inputType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            child: CustomTextFormField(
              controller: passwordController,
              isRequired: true,
              validator: (String value) {
                if (value.isEmpty) {
                  return AppLocalizations.of(context)!.enterPassword;
                } else if (value.length < 6) {
                  return AppLocalizations.of(context)!.inputMinimumSize(
                      AppLocalizations.of(context)!.thePassword, 6);
                }
                return null;
              },
              onSave: (String value) {
                setState(() => user.password = value);
              },
              inputFormatters: [LengthLimitingTextInputFormatter(80)],
              hintText: AppLocalizations.of(context)!.password,
              labelText: AppLocalizations.of(context)!.password,
              isPassword: true,
              focusNode: _passwordFocus,
              nextFocus: _confirmPasswordFocus,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            child: CustomTextFormField(
              isRequired: true,
              validator: (String value) {
                if (value.isEmpty) {
                  return AppLocalizations.of(context)!
                      .enterPasswordConfirmation;
                } else if (value.length < 6) {
                  return AppLocalizations.of(context)!.inputMinimumSize(
                      AppLocalizations.of(context)!.thePassword, 6);
                } else if (value != passwordController.text) {
                  return AppLocalizations.of(context)!.passwordsNotMatch;
                }
                return null;
              },
              inputFormatters: [LengthLimitingTextInputFormatter(191)],
              onSave: (String value) {},
              hintText: AppLocalizations.of(context)!.confirmPassword,
              labelText: AppLocalizations.of(context)!.confirmPassword,
              isPassword: true,
              focusNode: _confirmPasswordFocus,
              inputAction: TextInputAction.done,
            ),
          ),
          if (setting.value.enableTermsOfService ||
              setting.value.enablePrivacyPolicy)
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
              child: Text.rich(
                TextSpan(
                  text:
                      '${AppLocalizations.of(context)!.declareHaveReadAgreed} ',
                  style: poppinsRegular.copyWith(
                      fontSize: Dimensions.FONT_SIZE_SMALL,
                      color: Color.fromARGB(255, 76, 76, 76)),
                  children: <TextSpan>[
                    if (setting.value.enableTermsOfService)
                      TextSpan(
                        text: AppLocalizations.of(context)!.termsUse,
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      LegalTermsWidget(),
                                ),
                              ),
                        style: poppinsRegular.copyWith(
                          fontSize: Dimensions.FONT_SIZE_SMALL,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: Color.fromARGB(255, 76, 76, 76),
                        ),
                      ),
                    if (setting.value.enableTermsOfService &&
                        setting.value.enablePrivacyPolicy)
                      TextSpan(
                        text: ' ${AppLocalizations.of(context)!.and} ',
                        style: poppinsRegular.copyWith(
                          fontSize: Dimensions.FONT_SIZE_SMALL,
                          color: Color.fromARGB(255, 76, 76, 76),
                        ),
                      ),
                    if (setting.value.enablePrivacyPolicy)
                      TextSpan(
                        text: AppLocalizations.of(context)!.privacyPolicy,
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      PrivacyPolicyWidget(),
                                ),
                              ),
                        style: poppinsRegular.copyWith(
                          fontSize: Dimensions.FONT_SIZE_SMALL,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: Color.fromARGB(255, 76, 76, 76),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),

      // STEP 2
      Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Text(
            AppLocalizations.of(context)!.vehicleType,
            style: kSubtitleStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: Dimensions.FONT_SIZE_DEFAULT,
                color: Theme.of(context).primaryColor),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: setting.value.vehicleTypes.length,
              itemBuilder: (context, index) {
                VehicleType vehicleType =
                    setting.value.vehicleTypes.elementAt(index);
                bool selected = user.driver!.vehicleType?.id == vehicleType.id;
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        user.driver!.vehicleType = null;
                      } else {
                        user.driver!.vehicleType = vehicleType;
                      }
                    });
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context)
                            .primaryColor
                            .withOpacity(selected ? 1 : 0.5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    color: selected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).cardColor,
                    child: Container(
                      width: 120,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20, top: 10),
                            child: AutoSizeText(
                              vehicleType.name,
                              style: kSubtitleStyle.copyWith(
                                color: selected
                                    ? Theme.of(context).highlightColor
                                    : Theme.of(context).primaryColor,
                              ),
                              maxLines: 2,
                            ),
                          ),
                          if (vehicleType.picture != null)
                            CachedNetworkImage(
                              progressIndicatorBuilder:
                                  (context, url, progress) =>
                                      CircularProgressIndicator(
                                value: progress.progress,
                              ),
                              imageUrl: vehicleType.picture!.url,
                              height: 88,
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Visibility(
            visible: vehicleTypeError,
            child: Text(
              AppLocalizations.of(context)!.selectVehicleType,
              style: rubikBold.copyWith(
                  color: Colors.red, fontSize: Dimensions.FONT_SIZE_DEFAULT),
            ),
          ),
          Visibility(
            maintainState: true,
            visible: false,
            child: TextFormField(
              validator: (val) {
                if (user.driver!.vehicleType == null) {
                  setState(() => vehicleTypeError = true);
                  return 'error';
                } else {
                  setState(() => vehicleTypeError = false);
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            child: CustomTextFormField(
              isRequired: true,
              validator: (String value) {
                if (value.isEmpty || value.length <= 3) {
                  return AppLocalizations.of(context)!.enterVehicleBrand;
                }
                return null;
              },
              onSave: (String value) {
                setState(() => user.driver!.brand = value);
              },
              initialValue: user.driver!.brand,
              hintText: AppLocalizations.of(context)!.brand,
              labelText: AppLocalizations.of(context)!.brand,
              focusNode: _brandFocus,
              nextFocus: _modelFocus,
              inputType: TextInputType.name,
              inputFormatters: [LengthLimitingTextInputFormatter(150)],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            child: CustomTextFormField(
              isRequired: true,
              validator: (String value) {
                if (value.isEmpty || value.length <= 3) {
                  return AppLocalizations.of(context)!.enterVehicleModel;
                }
                return null;
              },
              onSave: (String value) {
                setState(() => user.driver!.model = value);
              },
              initialValue: user.driver!.model,
              hintText: AppLocalizations.of(context)!.model,
              labelText: AppLocalizations.of(context)!.model,
              focusNode: _modelFocus,
              nextFocus: _plateFocus,
              inputType: TextInputType.name,
              inputFormatters: [LengthLimitingTextInputFormatter(150)],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            child: CustomTextFormField(
              isRequired: true,
              validator: (String value) {
                if (value.isEmpty || value.length <= 3) {
                  return AppLocalizations.of(context)!.enterVehiclePlate;
                }
                return null;
              },
              onSave: (String value) {
                setState(() => user.driver!.plate = value);
              },
              initialValue: user.driver!.plate,
              hintText: AppLocalizations.of(context)!.plate,
              labelText: AppLocalizations.of(context)!.plate,
              focusNode: _plateFocus,
              nextFocus: _vehicleDocumentFocus,
              inputType: TextInputType.name,
              inputFormatters: [LengthLimitingTextInputFormatter(150)],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            child: CustomTextFormField(
              isRequired: true,
              validator: (String value) {
                if (value.isEmpty || value.length <= 3) {
                  return AppLocalizations.of(context)!.enterVehicleDocument;
                }
                return null;
              },
              onSave: (String value) {
                setState(() => user.driver!.vehicleDocument = value);
              },
              initialValue: user.driver!.vehicleDocument,
              hintText: AppLocalizations.of(context)!.vehicleDocument,
              labelText: AppLocalizations.of(context)!.vehicleDocument,
              focusNode: _vehicleDocumentFocus,
              inputAction: TextInputAction.done,
              inputType: TextInputType.text,
              inputFormatters: [LengthLimitingTextInputFormatter(150)],
            ),
          ),
        ],
      ),

      // STEP 3
      Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: AppLocalizations.of(context)!.driversLicensePhoto,
                  style: kSubtitleStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: Dimensions.FONT_SIZE_DEFAULT,
                      color: Theme.of(context).primaryColor),
                ),
                WidgetSpan(
                  child: Text(
                    ' *',
                    style: TextStyle(color: Theme.of(context).errorColor),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          ImagePickerWidget(
            defaultUrl: user.driver!.driverLicense,
            defaultImage: driverLicense,
            onImageChanged: (File? imagem) {
              setState(() {
                driverLicenseError = false;
                driverLicense = imagem;
              });
            },
          ),
          SizedBox(height: 5),
          Visibility(
            visible: driverLicenseError,
            child: Text(
              AppLocalizations.of(context)!.driversLicensePhoto,
              style: rubikBold.copyWith(
                  color: Colors.red,
                  fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL),
            ),
          ),
          Visibility(
            maintainState: true,
            visible: false,
            child: SizedBox(
              height: 50,
              width: 50,
              child: TextFormField(
                validator: (val) {
                  if (!widget.edit && driverLicense == null) {
                    setState(() => driverLicenseError = true);
                    return 'error';
                  } else {
                    setState(() => driverLicenseError = false);
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    ];
    setState(() => lastPage = fields.length - 1);

    return fields;
  }
}
