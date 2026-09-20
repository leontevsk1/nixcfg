# Проприетарный TOD-сборщик libfprint для сканеров FocalTech FT9201/FT9349
# и HOLTEK (USB 2808:c652 «FocalTech Fingerprint Device»).
# Источник пакета: AUR libfprint-ft9201 (ryenyuku), сборка Ubuntu 22.04 (.deb).
# Подключение:
#   services.fprintd.package = pkgs.fprintd.override { libfprint = libfprint-ft9201; };
{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  glib,
  gusb,
  nss,
  nspr,
  pixman,
  libgudev,
  systemd,
  openssl,
  # Ванильный libfprint — только ради заголовков в libfprint-2.pc (в .deb их нет)
  libfprint,
}:

stdenv.mkDerivation {
  pname = "libfprint-ft9201";
  version = "1.94.4+tod1-20250219";

  src = fetchurl {
    url = "https://github.com/ryenyuku/libfprint-ft9201/releases/download/1.94.4_20250219/libfprint-2-2_1.94.4+tod1-0ubuntu1.22.04.2_amd64_20250219.deb";
    sha256 = "fe8c5ebb685718075e1fc04f10378c001e149b80c283d2891318a50e0588401a";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];
  buildInputs = [
    glib.out
    gusb
    nss
    nspr
    pixman.out
    libgudev
    systemd
    openssl.out
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    dpkg-deb -x $src unpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 unpack/usr/lib/x86_64-linux-gnu/libfprint-2.so.2.0.0 \
      $out/lib/libfprint-2.so.2.0.0
    ln -s libfprint-2.so.2.0.0 $out/lib/libfprint-2.so.2
    ln -s libfprint-2.so.2.0.0 $out/lib/libfprint-2.so

    # plugdev не существует на NixOS — доступ по тегу uaccess
    mkdir -p $out/lib/udev/rules.d
    sed 's/GROUP="plugdev"/TAG+="uaccess"/' \
      unpack/lib/udev/rules.d/60-libfprint-2.rules \
      > $out/lib/udev/rules.d/60-libfprint-2.rules

    # pkg-config-файл: заголовки берём из ванильного libfprint (та же ветка 1.94.x),
    # линковка — на проприетарную библиотеку
    mkdir -p $out/lib/pkgconfig
    cat > $out/lib/pkgconfig/libfprint-2.pc <<EOF
prefix=$out
libdir=''${prefix}/lib
includedir=${libfprint}/include/libfprint-2

Name: libfprint-2
Description: Generic C API for fingerprint reader access (FT9201/FT9349/HOLTEK TOD build)
Version: 1.94.4
Libs: -L''${libdir} -lfprint-2
Cflags: -I''${includedir}
EOF

    runHook postInstall
  '';

  meta = {
    description = "Proprietary libfprint build for FocalTech FT9201/FT9349 and HOLTEK fingerprint readers";
    license = {
      free = false;
    };
    platforms = [ "x86_64-linux" ];
  };
}
