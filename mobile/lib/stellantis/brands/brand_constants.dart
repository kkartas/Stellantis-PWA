enum Brand {
  alfaRomeo,
  chrysler,
  citroen,
  dodge,
  ds,
  fiat,
  jeep,
  lancia,
  maserati,
  opel,
  peugeot,
  ram,
  vauxhall,
}

class BrandConstants {
  BrandConstants._();

  static const Map<Brand, String> redirectScheme = {
    Brand.citroen: 'mymacsdk',
    Brand.ds: 'mymdssdk',
    Brand.opel: 'mymopsdk',
    Brand.peugeot: 'mymap',
    Brand.vauxhall: 'mymvxsdk',
  };

  static const Map<Brand, String> realm = {
    Brand.citroen: 'clientsB2CCitroen',
    Brand.ds: 'clientsB2CDS',
    Brand.opel: 'clientsB2COpel',
    Brand.peugeot: 'clientsB2CPeugeot',
    Brand.vauxhall: 'clientsB2CVauxhall',
  };

  /// Two-letter brand code used in MQTT topics and API customer IDs.
  static const Map<Brand, String> brandCode = {
    Brand.citroen: 'AC',
    Brand.ds: 'DS',
    Brand.opel: 'OP',
    Brand.peugeot: 'AP',
    Brand.vauxhall: 'VX',
  };

  /// MQTT brand code (DS and VX share the OV broker partition).
  static const Map<Brand, String> mqttBrandCode = {
    Brand.citroen: 'AC',
    Brand.ds: 'AC',
    Brand.opel: 'OV',
    Brand.peugeot: 'AP',
    Brand.vauxhall: 'OV',
  };

  static const Map<Brand, String> tokenUrl = {
    Brand.citroen:
        'https://idpcvs.citroen.com/am/oauth2/access_token',
    Brand.ds: 'https://idpcvs.driveds.com/am/oauth2/access_token',
    Brand.opel: 'https://idpcvs.opel.com/am/oauth2/access_token',
    Brand.peugeot:
        'https://idpcvs.peugeot.com/am/oauth2/access_token',
    Brand.vauxhall:
        'https://idpcvs.vauxhall.co.uk/am/oauth2/access_token',
  };

  static const Map<Brand, String> authorizeUrl = {
    Brand.citroen:
        'https://idpcvs.citroen.com/am/oauth2/authorize',
    Brand.ds: 'https://idpcvs.driveds.com/am/oauth2/authorize',
    Brand.opel: 'https://idpcvs.opel.com/am/oauth2/authorize',
    Brand.peugeot:
        'https://idpcvs.peugeot.com/am/oauth2/authorize',
    Brand.vauxhall:
        'https://idpcvs.vauxhall.co.uk/am/oauth2/authorize',
  };

  /// Base URL for the PSA Connected Car v4 REST API.
  static const String apiBaseUrl =
      'https://api.groupe-psa.com/connectedcar/v4';

  /// Remote-access token endpoint; append client_id as query param.
  static const String remoteAccessTokenUrl =
      'https://api.groupe-psa.com'
      '/connectedcar/v4/virtualkey/remoteaccess/token?client_id=';

  /// MQTT broker host.
  static const String mqttHost = 'mwa.mpsa.com';

  /// MQTT broker port (TLS).
  static const int mqttPort = 8885;

  /// Token TTL in seconds for MQTT keep-alive.
  static const int mqttTokenTtlSeconds = 890;

  /// PSA date format used in API request/response bodies.
  static const String psaDateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'";

  /// PSA correlation ID date format.
  static const String psaCorrelationDateFormat = 'yyyyMMddHHmmssSSS';
}
