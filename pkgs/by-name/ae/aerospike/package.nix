{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  cmake,
  libtool,
  openssl,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "aerospike-server";
  version = "8.0.0.9";

  src = fetchFromGitHub {
    owner = "aerospike";
    repo = "aerospike-server";
    rev = version;
    hash = "sha256-3cXj+U8dtPk92fjUS+EDxuE2HklCIWhChjiLfJh5vHk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    autoconf
    automake
    cmake
    libtool
  ];
  buildInputs = [
    openssl
    zlib
  ];

  dontUseCmakeConfigure = true;

  preBuild = ''
    patchShebangs build/gen_version
    substituteInPlace build/gen_version --replace 'git describe' 'echo ${version}'
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp target/Linux-x86_64/bin/asd $out/bin/asd
  '';

  meta = {
    description = "Flash-optimized, in-memory, NoSQL database";
    mainProgram = "asd";
    homepage = "https://aerospike.com/";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ kalbasit ];
  };
}
