{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "ghauri";
  version = "1.3.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "r0oth3x49";
    repo = "ghauri";
    tag = version;
    hash = "sha256-GEUuQMtp8XO32uOIILWiMfngPXx/3vCKk+YbA0E13rg=";
  };

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    chardet
    colorama
    requests
    tldextract
  ];

  # Project has no tests
  doCheck = false;

  pythonImportsCheck = [
    "ghauri"
  ];

  meta = {
    description = "Tool for detecting and exploiting SQL injection security flaws";
    homepage = "https://github.com/r0oth3x49/ghauri";
    changelog = "https://github.com/r0oth3x49/ghauri/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "ghauri";
  };
}
