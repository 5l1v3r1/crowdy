git checkout gh-pages
rsync -r --exclude="README.md" --exclude="doc" /Users/mert/Public/Projects/dart/crowdy/build/web/* .;
ssh-add ~/.ssh/github
git add --all
git commit -m "Updating public web"
git push origin gh-pages