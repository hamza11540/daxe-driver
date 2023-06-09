import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:validators/validators.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../controllers/user_controller.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/images.dart';
import '../../../helper/styles.dart';
import '../../../models/custom_exception.dart';
import '../../../models/exceptions_enum.dart';
import '../../../models/screen_argument.dart';
import '../../../repositories/user_repository.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custom_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends StateMVC<LoginScreen> {
  late UserController _userCon;
  late FToast fToast;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool loading = false;
  bool rememberMe = false;
  String email = "";
  String password = "";

  LoginScreenState() : super(UserController()) {
    _userCon = controller as UserController;
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _userCon.scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: ClampingScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Center(
                        child: Image.asset(Images.logo,
                            height: MediaQuery.of(context).size.height * 0.2)),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      child: CustomTextFormField(
                        hintText: AppLocalizations.of(context)!.email,
                        labelText: AppLocalizations.of(context)!.email,
                        focusNode: _emailFocus,
                        nextFocus: _passwordFocus,
                        inputType: TextInputType.emailAddress,
                        inputAction: TextInputAction.next,
                        onSave: (String value) {
                          email = value;
                        },
                        isRequired: true,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "\u26A0 ${AppLocalizations.of(context)!.enterEmail}";
                          } else if (!isEmail(value)) {
                            return "\u26A0 ${AppLocalizations.of(context)!.enterValidEmail}";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      child: CustomTextFormField(
                          nextFocus: FocusNode(),
                          hintText: AppLocalizations.of(context)!.password,
                          labelText: AppLocalizations.of(context)!.password,
                          isPassword: true,
                          focusNode: _passwordFocus,
                          inputType: TextInputType.visiblePassword,
                          inputAction: TextInputAction.done,
                          onSave: (String value) {
                            password = value;
                          },
                          isRequired: true,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return "\u26A0 ${AppLocalizations.of(context)!.enterPassword}";
                            }
                            return null;
                          }),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      margin: const EdgeInsets.only(
                          left: Dimensions.PADDING_SIZE_DEFAULT,
                          right: Dimensions.PADDING_SIZE_DEFAULT),
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: const Offset(0, 1)),
                            ],
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(2)),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: loading
                              ? () {}
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    setState(() => loading = true);
                                    await _userCon
                                        .doLogin(email, password, rememberMe)
                                        .then((value) {
                                      Navigator.pushReplacementNamed(
                                          context, "/Home");
                                    }).catchError((error) {
                                      if (error.runtimeType ==
                                              CustomException &&
                                          error.exception ==
                                              ExceptionsEnum.userStatus) {
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                          '/DriverStatus',
                                          arguments: ScreenArgument({
                                            'status': currentUser
                                                .value.driver!.status!,
                                            'observacao': currentUser
                                                .value.driver!.statusObservation
                                          }),
                                        );
                                      } else {
                                        fToast.showToast(
                                            child: CustomToast(
                                              backgroundColor: Colors.red,
                                              icon: Icon(Icons.close,
                                                  color: Colors.white),
                                              text: error.toString(),
                                              textColor: Colors.white,
                                            ),
                                            gravity: ToastGravity.BOTTOM,
                                            toastDuration:
                                                const Duration(seconds: 3));
                                      }
                                    });
                                    setState(() => loading = false);
                                    return;
                                  }
                                },
                          child: loading
                              ? CircularProgressIndicator(
                                  color: Theme.of(context).highlightColor)
                              : Text(
                                  AppLocalizations.of(context)!.login,
                                  style: poppinsSemiBold.copyWith(
                                      color: Theme.of(context).highlightColor),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: loading
                                ? () {}
                                : () {
                                    Navigator.of(context)
                                        .pushNamed('/ForgotPassword');
                                  },
                            child: Text(
                              AppLocalizations.of(context)!.forgetPassword,
                              textAlign: TextAlign.end,
                              style: poppinsRegular.copyWith(
                                color: Colors.lightBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: loading
                    ? () {}
                    : () {
                        Navigator.of(context).pushNamed('/Signup');
                      },
                child: SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.registerAsDriver,
                        style: poppinsRegular.copyWith(
                          color: Colors.lightBlue,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
