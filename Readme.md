# Datenbank
- Server: mariadb
- Datenbank: mediawiki
- Nutzer: root
- Passwort: root

# Mediawiki
- Benutzer: dan
- Passwort: hSVVWcPwdZ6y

# LocalSettings.php
- enableSemantics(); (lokal)
- $wgMainCacheType = CACHE_NONE;
- $wgCacheDirectory = false;
- docker-compose exec mediawiki maintenance/update.php --quick

# Skin
- wfLoadSkin( 'chameleon' );
- $wgDefaultSkin = "chameleon";

# Extensions
- docker cp alcuin_mediawiki_1:/var/www/html/extensions extensions/
