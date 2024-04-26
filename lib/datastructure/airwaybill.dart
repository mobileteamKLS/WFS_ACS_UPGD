class AWB {
  String shiptype;
  String origin;

  String prefix;
  String mawbno;
  String hawbno;
  String nop;
  String grwt;
  String natureofgoods;
  String ff;
  bool isselect;
  int index;

  AWB(
      {required this.shiptype,
        required this.origin,
        required this.prefix,
        required this.mawbno,
        required this.hawbno,
        required this.nop,
        required this.grwt,
        required this.natureofgoods,
        required this.isselect,
        required this.ff,
        required this.index});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AWB &&
              runtimeType == other.runtimeType &&
              mawbno == other.mawbno;

  @override
  int get hashCode => mawbno.hashCode;
}

class HAWB {
  // String GrWt;

  String GrWt;
  int MAWBId;
  int HAWBId;
  String NatureOfGoods;
  String NoP;
  String hawbNo;
  String mawbNo;

  String origin;
  String prefix;

  HAWB({
    required this.GrWt,
    required this.origin,
    required this.prefix,
    required this.mawbNo,
    required this.hawbNo,
    required this.MAWBId,
    required this.HAWBId,
    required this.NoP,
    required this.NatureOfGoods,
  });
}

class MAWB {
  // String GrWt;

  String GrWt;
  int MAWBId;
  String NatureOfGoods;
  String NoP;
  String mawbNo;
  String origin;
  String prefix;
  String shipmentType;

  MAWB({
    required this.GrWt,
    required this.origin,
    required this.prefix,
    required this.mawbNo,
    required this.MAWBId,
    required this.NoP,
    required this.NatureOfGoods,
    required this.shipmentType,
  });
}

class MAWBDropoff {
  // String GrWt;

  String GrWt;
  int MAWBId;
  String NatureOfGoods;
  String NoP;
  String mawbNo;
  String destination;
  String prefix;
  String freightForwarder;

  MAWBDropoff({
    required this.GrWt,
    required this.destination,
    required this.prefix,
    required this.mawbNo,
    required this.MAWBId,
    required this.NoP,
    required this.NatureOfGoods,
    required this.freightForwarder,
  });
}