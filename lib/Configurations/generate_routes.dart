

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signloop/Configurations/app_routes.dart';
import 'package:signloop/contract/contract_page.dart';
import 'package:signloop/customer/add_customer.dart';
import 'package:signloop/customer/customer_details.dart';
import 'package:signloop/customer/customer_list_page.dart';
import 'package:signloop/customer/customer_page.dart';
import 'package:signloop/home.dart';

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
        ];
    }

