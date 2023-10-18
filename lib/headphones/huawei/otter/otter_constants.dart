class OtterConst {

  static const BUDS_4I = 0;
  static const BUDS_PRO = 1;

  @Deprecated("This seems to not work... use [btDevNameRegex] instead")
  static final btMacRegex = RegExp(r'60:AA:..:..:..:7E', caseSensitive: false);

  // Copied straight from decompiled app
  static final btDevNameRegex =
      [
        RegExp(r'^(?=(HUAWEI FreeBuds 4i))', caseSensitive: true),
        RegExp(r'^(?=(HUAWEI FreeBuds Pro))', caseSensitive: true)
      ];
  
  static final names =
      [
        'Huawei Freebuds 4i',   
        'Huawei Freebuds Pro'     
      ];

  static final imageAsset = [
    'assets/app_icons/ic_launcher.png',
    'assets/app_icons/freebuds_pro_one.png',
  ];
}
