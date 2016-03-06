![Merci-Michel](http://merci-michel.net/push/img/logo_mm_readme_git.png)

## Setup

Make sure you have at least node 0.12

`npm install`

## Configure

For the different environments, edit the *Makefile*, then execute `make decrypt_conf`.

Configure host in grunt/config/local.json (there's a sample you can duplicate).

## Extract Certificate and Private Key files from .pfx

https://wiki.cac.washington.edu/display/infra/Extracting+Certificate+and+Private+Key+Files+from+a+.pfx+File
When uploading, remove the beginning down to : -----BEGIN

## Run locally

`grunt`

## Build & Deploy

### Preprod

`grunt build` and choose **preprod**.

Upload on FTP the dist folder and be careful about overwriting the *.htaccess*.

### Staging

`grunt build` and choose **staging**.

Then, `grunt gaeDeploy:staging`

On GCP, in the menu *App Engine > Versions*, select the **staging** module and **make default** the version you just deployed.

### Prod

`grunt build` and choose prod.

Then, `grunt gaeDeploy:prod`

On GCP, in the menu *App Engine > Versions*, select the **default** module and **make default** the version you just deployed.

## Tips

Default search in Sublime Text:
`-node_modules,-dist/js,-dist/css,-app.sublime-workspace`
