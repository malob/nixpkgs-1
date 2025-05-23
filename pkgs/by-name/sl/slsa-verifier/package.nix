{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "slsa-verifier";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "slsa-framework";
    repo = "slsa-verifier";
    rev = "v${version}";
    hash = "sha256-wOK0S0XJ0LbFSr8Z/KEnKolq0u/SyBNDiugOAD0OmgY=";
  };

  vendorHash = "sha256-nvksImn3c04ato67oPnYkJj8TgxlP+Pjer+LdvfdhD8=";

  env.CGO_ENABLED = 0;

  subPackages = [ "cli/slsa-verifier" ];

  tags = [ "netgo" ];

  ldflags = [
    "-s"
    "-w"
    "-X sigs.k8s.io/release-utils/version.gitVersion=${version}"
  ];

  doCheck = false;

  meta = {
    homepage = "https://github.com/slsa-framework/slsa-verifier";
    changelog = "https://github.com/slsa-framework/slsa-verifier/releases/tag/v${version}";
    description = "Verify provenance from SLSA compliant builders";
    mainProgram = "slsa-verifier";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      developer-guy
      mlieberman85
    ];
  };
}
