

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signloop/Configurations/app_routes.dart';
import 'package:signloop/contract/add_contract.dart';
import 'package:signloop/contract/contract_page.dart';
import 'package:signloop/contract/update_contract.dart';
import 'package:signloop/customer/add_customer.dart';
import 'package:signloop/customer/customer_details.dart';
import 'package:signloop/customer/customer_list_page.dart';
import 'package:signloop/customer/customer_page.dart';
import 'package:signloop/home.dart';
import 'package:signloop/login/login_page.dart';
import 'package:signloop/login/register_page.dart';
import 'package:signloop/models/contract.dart';

class GenerateRoutes {
    static final getPages = [
            GetPage(name: AppRoutes.home, page:() => Home()),
            GetPage(name: AppRoutes.customerPage, page:() => CustomerPage()),
            GetPage(name: AppRoutes.contractPage, page:() => ContractPage()),
            GetPage(name: AppRoutes.customerListPage, page:() => CustomerListPage()),
            GetPage(name: AppRoutes.addCustomerPage, page:() => AddCustomerPage()),
            GetPage(
      name: AppRoutes.customerDetails,
      page: () {
        final customerId = Get.arguments as int?;
        if (customerId == null) {
          print('❌ No customerId provided in arguments');
          return const Scaffold(body: Center(child: Text('Erreur: ID manquant')));
        }
        return CustomerDetailsPage(customerId: customerId);
      },
    ),
            GetPage(name: AppRoutes.addContractPage, page:() => AddContractPage()),
            GetPage(
      name: AppRoutes.updateContractPage,
      page: () {
        final contract = Get.arguments as Contract?;
        if (contract == null) {
          print('❌ No contract provided in arguments');
          return const Scaffold(body: Center(child: Text('Erreur: Contrat manquant')));
        }
        return UpdateContractPage(contract: contract);
      },
    ),
            GetPage(name: AppRoutes.loginPage, page:() => LoginPage()),
            GetPage(name: AppRoutes.registerPage, page:() => RegisterPage()),
        ];
    }

