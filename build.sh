#!/bin/bash

rm -rf deepstack-tutorials
git clone --filter=tree:0 https://github.com/khulnasoft/deepstack-tutorials.git

cd deepstack-tutorials
echo "Installing requirements for deepstack-tutorials..."
python3 -m ensurepip --upgrade
python3 -m pip install -r requirements.txt
echo "Generating markdown files into ./content/tutorials..."
python3 scripts/generate_markdowns.py --index index.toml --notebooks all --output ../content/tutorials
cd ..
ls ./content/tutorials
mkdir ./static/downloads
echo "Copying notebook files into ./static/downloads..."
cp ./deepstack-tutorials/tutorials/*.ipynb ./static/downloads
ls ./static/downloads

rm -rf deepstack-integrations
git clone --filter=tree:0 https://github.com/khulnasoft/deepstack-integrations.git
cp ./deepstack-integrations/integrations/*.md ./content/integrations

rm -rf deepstack-advent
git clone --filter=tree:0 https://$GITHUB_USER_NAME:$GH_DEEPSTACK_HOME_PAT@github.com/khulnasoft/advent-of-deepstack.git deepstack-advent
cp -R ./deepstack-advent/challenges/* ./content/advent-of-deepstack

npm install

# Use "localhost" if VERCEL_URL is not set
PREVIEW_URL="${VERCEL_URL:-localhost}"
# Use PREVIEW_URL if SITE_URL is not set
DEPLOY_URL="${SITE_URL:-$PREVIEW_URL}"

# Adds the directory to relative image paths in blog posts
if [[ "$DEPLOY_URL" != "localhost" ]]; then
    find ./content/blog -name "index.md" -type f -exec bash -c '
    dir=$(dirname "{}" | sed -e "s,^.*content/blog/,," -e "s,/.*,,");
    sed -i "/\(http\|\/images\)/! s~!\[\([^]]*\)\]([./]*\([^)]*\))~![\1]($dir/\2)~g" "{}"
    ' \;

    find ./content/advent-of-deepstack -name "index.md" -type f -exec bash -c '
    dir=$(dirname "{}" | sed -e "s,^.*content/advent-of-deepstack/,," -e "s,/.*,,");
    sed -i "/\(http\|\/images\)/! s~!\[\([^]]*\)\]([./]*\([^)]*\))~![\1]($dir/\2)~g" "{}"
    ' \;
fi

echo "Deploy URL: ${DEPLOY_URL}"
hugo -b https://${DEPLOY_URL}
