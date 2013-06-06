msg=$(git log -1 --format="%h %ad %ae" --date=short)
commit=($msg)
ref=${commit[0]}
date=${commit[1]}
email=${commit[2]}
name=${email%%@*}
domain=${email##*@}

js=module.exports\={developer:\'$name\',domain:\'$domain\',ref:\'$ref\',date:\'$date\'}
echo $js > app/lib/info.js
hem build
s3cmd -c ~/.s3cfg-personal put --acl-public public/index.html public/application* s3://luminosity.astrojs.org/alpha/