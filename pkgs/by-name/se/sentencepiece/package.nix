{
  lib,
  fetchFromGitHub,
  stdenv,
  cmake,
  gperftools,

  withGPerfTools ? true,
}:

stdenv.mkDerivation rec {
  pname = "sentencepiece";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "sentencepiece";
    tag = "v${version}";
    sha256 = "sha256-tMt6UBDqpdjAhxAJlVOFFlE3RC36/t8K0gBAzbesnsg=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = lib.optionals withGPerfTools [ gperftools ];

  outputs = [
    "bin"
    "dev"
    "out"
  ];

  # https://github.com/google/sentencepiece/issues/754
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '\$'{exec_prefix}/'$'{CMAKE_INSTALL_LIBDIR} '$'{CMAKE_INSTALL_FULL_LIBDIR} \
      --replace '\$'{prefix}/'$'{CMAKE_INSTALL_INCLUDEDIR} '$'{CMAKE_INSTALL_FULL_INCLUDEDIR}
  '';

  meta = with lib; {
    homepage = "https://github.com/google/sentencepiece";
    description = "Unsupervised text tokenizer for Neural Network-based text generation";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ pashashocky ];
  };
}
