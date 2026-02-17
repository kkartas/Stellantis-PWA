# Developer Information

## Contributing

Before opening a pull request:

```bash
poetry install --no-root
prospector
```

## Architecture Notes

- Backend and integration logic remains in Python modules under `psa_car_controller/psacc` and `psa_car_controller/psa`.
- Web runtime now serves a static PWA from `psa_car_controller/web/pwa`.
- API + PWA routes are in `psa_car_controller/web/view/api.py`.

## API Documentation

The upstream API specification is in `api_spec.md`.

Example call from code:

```python
myp.api().get_car_last_position(myp.get_vehicle_id_with_vin("myvin"))
```

## Analysing Requests

To inspect traffic between the mobile app and PSA servers, use mitmproxy.

You need the client certificate from the APK (`assets/MWPMYMA1.pfx`):

```bash
openssl pkcs12 -in MWPMYMA1.pfx -out MWPMYMA1.pem -nodes
mitmproxy --set client_certs=MWPMYMA1.pem
```

For Android app traffic, use a rooted phone/emulator and install system CAs:
https://docs.mitmproxy.org/stable/howto-install-system-trusted-ca-android/
