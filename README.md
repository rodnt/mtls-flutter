# mtls_example_flutter
A simple example for how to use private key and certificate in you flutter app with a server example https://github.com/rodnt/flask-mtls



#### Install 

1. Download flutter enviroment: https://flutter-ko.dev/get-started/install
2. Configure the mtls server at https://github.com/rodnt/flask-mtls

#### Usage 

1. Copy ca.crt,certificate.crt and private.key generated from flask-mtls to anyplace that you want.
2. Add to EXPORT env at terminal (iterm2, Terminator.. etc..) 

```bash
# b 0 from macOS and w 0 from linux 
export PRIVATE_KEY_BASE64="$(base64 -b 0 assets/keys/private.key)"; export CERTIFICATE_BASE64="$(base64 -b 0 assets/keys/certificate.crt)"
``` 

3. Inside the project run the following command

```bash
flutter run --release --dart-define=PRIVATE_KEY_BASE64=$PRIVATE_KEY_BASE64 --dart-define=CERTIFICATE_BASE64=$CERTIFICATE_BASE64
```

4. Test the app :)

5. You can get the APK at `mtls_example_flutter/build/app/outputs/flutter-apk/`

