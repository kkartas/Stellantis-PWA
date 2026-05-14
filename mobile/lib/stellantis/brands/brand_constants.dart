// Brand constants — client_id/secret extracted in Phase 2 via tools/extract_secrets/
enum Brand { citroen, ds, opel, peugeot, vauxhall }

class BrandConstants {
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

  static const Map<Brand, String> tokenUrl = {
    Brand.citroen: 'https://idpcvs.citroen.com/am/oauth2/access_token',
    Brand.ds: 'https://idpcvs.driveds.com/am/oauth2/access_token',
    Brand.opel: 'https://idpcvs.opel.com/am/oauth2/access_token',
    Brand.peugeot: 'https://idpcvs.peugeot.com/am/oauth2/access_token',
    Brand.vauxhall: 'https://idpcvs.vauxhall.co.uk/am/oauth2/access_token',
  };
}
