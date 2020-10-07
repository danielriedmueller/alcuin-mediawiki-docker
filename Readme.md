# Datenbank
- Server: mariadb
- Datenbank: mediawiki
- Nutzer: root
- Passwort: root

# Mediawiki
- Benutzer: dan
- Passwort: hSVVWcPwdZ*6**y

# LocalSettings.php
- enableSemantics(); (lokal)
- docker-compose exec mediawiki maintenance/update.php --quick

# Skin
- https://github.com/jthingelstad/foreground
- wfLoadSkin( 'foreground' );
- $wgDefaultSkin = "foreground";<
