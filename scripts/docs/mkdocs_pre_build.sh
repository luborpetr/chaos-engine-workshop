#!/bin/sh
#
# Resolve MkDocs Dependencies

set -euxo pipefail

pip --cache-dir .pip install -r ./scripts/docs/mkdocs_requirements.txt

echo $VERSION

sed -i "s/<!-- version -->/${VERSION:-Local Build}/g" docs/mkdocs.yml
