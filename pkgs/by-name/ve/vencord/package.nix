{
  curl,
  fetchFromGitHub,
  git,
  jq,
  lib,
  nix-update,
  nodejs,
  pnpm_10,
  stdenv,
  writeShellScript,
  buildWebExtension ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vencord";
  version = "1.12.7";

  src = fetchFromGitHub {
    owner = "Vendicated";
    repo = "Vencord";
    rev = "v${finalAttrs.version}";
    hash = "sha256-MS88KCH8ZdLyKoR0K45CSJutZSKUhz4FAE2VtrSx0ic=";
  };

  pnpmDeps = pnpm_10.fetchDeps {
    inherit (finalAttrs) pname src;
    fetcherVersion = 2;
    hash = "sha256-JP9HOaP3DG+2F89tC77JZFD0ls35u/MzxNmvMCbBo9Y=";
  };

  nativeBuildInputs = [
    git
    nodejs
    pnpm_10.configHook
  ];

  env = {
    VENCORD_REMOTE = "${finalAttrs.src.owner}/${finalAttrs.src.repo}";
    VENCORD_HASH = "${finalAttrs.version}";
  };

  buildPhase = ''
    runHook preBuild

    pnpm run ${if buildWebExtension then "buildWeb" else "build"} \
      -- --standalone --disable-updater

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r dist/${lib.optionalString buildWebExtension "chromium-unpacked/"} $out
    cp package.json $out # Presence is checked by Vesktop.

    runHook postInstall
  '';

  # We need to fetch the latest *tag* ourselves, as nix-update can only fetch the latest *releases* from GitHub
  # Vencord had a single "devbuild" release that we do not care about
  passthru.updateScript = writeShellScript "update-vencord" ''
    export PATH="${
      lib.makeBinPath [
        curl
        jq
        nix-update
      ]
    }:$PATH"
    ghTags=$(curl ''${GITHUB_TOKEN:+" -u \":$GITHUB_TOKEN\""} "https://api.github.com/repos/Vendicated/Vencord/tags")
    latestTag=$(echo "$ghTags" | jq -r .[0].name)

    echo "Latest tag: $latestTag"

    exec nix-update --version "$latestTag" "$@"
  '';

  meta = {
    description = "Vencord web extension";
    homepage = "https://github.com/Vendicated/Vencord";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      donteatoreo
      FlafyDev
      Gliczy
      NotAShelf
      Scrumplex
    ];
  };
})
