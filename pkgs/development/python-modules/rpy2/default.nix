{
  stdenv,
  lib,
  buildPythonPackage,
  fetchPypi,
  isPyPy,
  R,
  libdeflate,
  rWrapper,
  rPackages,
  pcre,
  xz,
  bzip2,
  zlib,
  zstd,
  icu,
  ipython,
  jinja2,
  pytz,
  pandas,
  numpy,
  cffi,
  tzlocal,
  simplegeneric,
  pytestCheckHook,
  extraRPackages ? [ ],
}:

buildPythonPackage rec {
  version = "3.5.17";
  format = "setuptools";
  pname = "rpy2";

  disabled = isPyPy;
  src = fetchPypi {
    inherit version pname;
    hash = "sha256-2/8Iww89eRYZImI4WKWztoo/uo7hdH1q9BvEumjz1YI=";
  };

  patches = [
    # R_LIBS_SITE is used by the nix r package to point to the installed R libraries.
    # This patch sets R_LIBS_SITE when rpy2 is imported.
    ./rpy2-3.x-r-libs-site.patch
  ];

  postPatch = ''
    substituteInPlace 'rpy2/rinterface_lib/embedded.py' --replace '@NIX_R_LIBS_SITE@' "$R_LIBS_SITE"
    substituteInPlace 'requirements.txt' --replace 'pytest' ""
  '';

  buildInputs = [
    pcre
    xz
    bzip2
    zlib
    zstd
    icu
    libdeflate
  ]
  ++ (with rPackages; [
    # packages expected by the test framework
    ggplot2
    dplyr
    RSQLite
    broom
    DBI
    dbplyr
    hexbin
    lazyeval
    lme4
    tidyr
  ])
  ++ extraRPackages
  ++ rWrapper.recommendedPackages;

  nativeBuildInputs = [
    R # needed at setup time to detect R_HOME (alternatively set R_HOME explicitly)
  ];

  propagatedBuildInputs = [
    ipython
    jinja2
    pytz
    pandas
    numpy
    cffi
    tzlocal
    simplegeneric
  ];

  # https://github.com/rpy2/rpy2/issues/1111
  disabledTests = [
    "test_parse_incomplete_error"
    "test_parse_error"
    "test_parse_error_when_evaluting"
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    homepage = "https://rpy2.github.io/";
    description = "Python interface to R";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ joelmo ];
  };
}
