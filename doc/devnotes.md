# Dev Notes

## texts

We have switched to http2 to serve the texts.alpheios.net host. The default distribution of apache2 
that comes with Ubuntu 16.04 does not come with http2 support. Upgrading to Ubuntu 18.04 will require
an update to the puppet bootstrap setup, because there is no puppet 4 distribution package for
Ubuntu 18.04 (bionic).

So a few manual post-install steps are required. See [texts-http2-upgrade-steps.md](texts-http2-upgrade-seteps.md)

