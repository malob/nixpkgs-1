{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  cmake,
  qmake,
  qtbase,
  qtsvg,
  qtx11extras ? null, # Qt 5 only
  kwindowsystem,
  qtwayland,
  libX11,
  libXext,
  qttools,
  wrapQtAppsHook,
  gitUpdater,

  qt6Kvantum ? null,
}:
let
  isQt5 = lib.versionOlder qtbase.version "6";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "qtstyleplugin-kvantum${lib.optionalString isQt5 "5"}";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "tsujan";
    repo = "Kvantum";
    rev = "V${finalAttrs.version}";
    hash = "sha256-G1yqToqYVnV/ag//b4C3jUvh2ayIhV3bEavfhpiF0p0=";
  };

  nativeBuildInputs = [
    cmake
    qmake
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtsvg
    libX11
    libXext
  ]
  ++ lib.optionals isQt5 [ qtx11extras ]
  ++ lib.optionals (!isQt5) [
    kwindowsystem
    qtwayland
  ];

  sourceRoot = "${finalAttrs.src.name}/Kvantum";

  patches = [
    (fetchpatch {
      # add xdg dirs support
      url = "https://github.com/tsujan/Kvantum/commit/01989083f9ee75a013c2654e760efd0a1dea4a68.patch";
      hash = "sha256-HPx+p4Iek/Me78olty1fA0dUNceK7bwOlTYIcQu8ycc=";
      stripLen = 1;
    })
  ];

  postPatch = ''
    substituteInPlace style/CMakeLists.txt \
      --replace-fail '"''${_Qt6_PLUGIN_INSTALL_DIR}/' "\"$out/$qtPluginPrefix/" \
      --replace-fail '"''${_Qt5_PLUGIN_INSTALL_DIR}/' "\"$out/$qtPluginPrefix/"
  '';

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_QT5" isQt5)
  ];

  postInstall = lib.optionalString isQt5 ''
    # make default Kvantum themes available for Qt 5 apps
    mkdir -p "$out/share"
    ln -s "${qt6Kvantum}/share/Kvantum" "$out/share/Kvantum"
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "V";
  };

  meta = {
    description = "SVG-based Qt5 theme engine plus a config tool and extra themes";
    homepage = "https://github.com/tsujan/Kvantum";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      romildo
      Scrumplex
    ];
  };
})
