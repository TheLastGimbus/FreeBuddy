class Otter {
  static const String name = 'Huawei Freebuds 4i';

  @Deprecated("This seems to not work... use [btDevNameRegex] instead")
  static final btMacRegex = RegExp(r'60:AA:..:..:..:7E', caseSensitive: false);

  // Copied straight from decompiled app
  static final btDevNameRegex =
      RegExp(r'^(?=(HUAWEI FreeBuds 4i))', caseSensitive: true);
}
