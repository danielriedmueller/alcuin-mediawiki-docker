Alcuin
===============
##Installation
<pre>
docker-compose up --build -d
</pre>
- Konfiguration in der Weboberflaeche (http://localhost:8001/mw-config)
- LocalSettings.php herunterladen und in Projektverzeichnis speichern
- LocalSettings.php anpassen
- Zeile 18 in docker-compose.yml einkommentieren (- ./LocalSettings.php:/var/www/html/LocalSettings.php)
- docker-compose down und docker-compose up --build -d
- docker-compose exec mediawiki maintenance/update.php --quick

####Datenbank Konfiguration
- Server: mariadb
- Datenbank: mediawiki
- root
- root

####Mediawiki Konfiguration
- admin
- adminpassword

####LocalSettings.php Anpassungen
<pre>
wfLoadExtension( 'ParserFunctions' );
wfLoadExtension( 'Alcuin' );
wfLoadExtension( 'DisplayTitle' );
wfLoadExtension( 'Elastica' );
wfLoadExtension( 'PageForms' );
wfLoadExtension( 'PageSchemas' );
wfLoadExtension( 'CirrusSearch' );
wfLoadExtension( 'Network' );
wfLoadExtension( 'SemanticCite' );
enableSemantics();

require_once "$IP/extensions/SemanticDrilldown/SemanticDrilldown.php";

$wgRestrictDisplayTitle = false;
$wgPageFormsUseDisplayTitle = true;

$wgDisableSearchUpdate = false;
$wgCirrusSearchServers = [ 'elasticsearch' ];
$wgSearchType = 'CirrusSearch';
$wgCirrusSearchUseCompletionSuggester = 'yes';
$wgCirrusSearchIndexBaseName = 'mediawiki';

$wgShowExceptionDetails = true;
$wgShowDBErrorBacktrace = true;

$wgGroupPermissions['user']['generatepages'] = true;
$wgGroupPermissions['*']['edit'] = false;
$wgGroupPermissions['*']['createpage'] = false;
$wgGroupPermissions['admin']['edit'] = true;
$wgGroupPermissions['admin']['createpage'] = true;

$egScssCacheType = CACHE_NONE;
$wgPageFormsFormCacheType = CACHE_NONE;
</pre>

####ontology2smw
- git clone https://github.com/TIBHannover/ontology2smw.git
- cd ontology2smw
- pip install --upgrade setuptools
- python setup.py install
- http://localhost:8001/index.php/Special:UserRights -> admin user, add bot to user group
- http://localhost:8001/index.php/Special:BotPasswords -> generate bot password
- add password to ontology2swm/wikidetails.yml
    - e.g. 
    <pre>
    host: localhost:8001
    path: /
    scheme: http
    username: Admin@ontology # bot username
    password: j2mkt18rjlnj8rhuqq3gt17km8q1sn7s
    </pre>
- ontology2smw --format ttl --ontology http://purl.org/spar/fabio.ttl --write

####Elasticsearch einrichten
<pre>
wfLoadExtension( 'CirrusSearch' );
require_once "$IP/extensions/CirrusSearch/tests/jenkins/FullyFeaturedConfig.php";
$wgCirrusSearchServers = [ 'elasticsearch' ];

# Installs the dependencies for Elastica
docker-compose exec mediawiki composer --working-dir=/var/www/html/extensions/Elastica install 
# Configure the search index and populate it with content
docker-compose exec mediawiki php extensions/CirrusSearch/maintenance/UpdateSearchIndexConfig.php
docker-compose exec mediawiki php extensions/CirrusSearch/maintenance/ForceSearchIndex.php --skipLinks --indexOnSkip
docker-compose exec mediawiki php extensions/CirrusSearch/maintenance/ForceSearchIndex.php --skipParse
# Process the job queue. You need to do this any time you add/update content and want it updated in ElasticSearch
docker-compose exec mediawiki php maintenance/runJobs.php
docker-compose exec mediawiki php extensions/CirrusSearch/maintenance/UpdateSuggesterIndex.php
$wgSearchType = 'CirrusSearch';
$wgCirrusSearchIndexBaseName = 'mediawiki';
</pre>

####Elastic search vm memory
- pactl load-module module-detect
- sysctl -w vm.max_map_count=262144

#### Extensions bearbeiten
- docker cp alcuin_mediawiki_1:/var/www/html/extensions extensions/
- docker cp alcuin_mediawiki_1:/var/www/html/. .


composer config minimum-stability dev

####PageForms bugfix 
- https://github.com/danielriedmueller/PageForms.git
- ext.pf.select2.comobox.js Zeile 169
<pre>
else if (Object.keys(data).length !== 0) {
    for (var key in data) {
        values.push({
            id: data[key], text: data[key]
        });
    }
}
</pre>

####XML Parser
- sudo apt install python3-bs4 
- sudo apt install python3-pip
- pip install lxml

Page "Utrum_contradictio_sit_maxima_oppositio	" was not imported because the name to which it would be imported is invalid on this wiki.

####Import rdf2smw
<pre>
./rdf2smw --in alcuin.ttl --out alcuin.xml

php maintenance/importDump.php import/vocabularies_templates.xml
php maintenance/importDump.php import/vocabularies_properties.xml
php maintenance/importDump.php import/vocabularies.xml
php maintenance/importDump.php import/alcuin_templates.xml
php maintenance/importDump.php import/alcuin_properties.xml
(python3 XMLParser/soup.py import/alcuin.xml > import/alcuin_souped.xml)
php maintenance/importDump.php import/alcuin_souped.xml --no-updates

php maintenance/rebuildrecentchanges.php 
php maintenance/initSiteStats.php --update
maintenance/update.php --quick
</pre>

###Datenbank Dump
<pre>
docker-compose exec mariadb mysqldump --default-character-set=binary --user=root --password=root mediawiki > dump_of_wikidb.sql
docker-compose exec mariadb mysqladmin -u root -p drop mediawiki
docker-compose exec mariadb mysqladmin -u root -p create mediawiki
</pre>

#### Rebuild DB
<pre>
docker-compose exec mariadb mysqladmin -u root -p drop mediawiki
docker-compose exec mariadb mysqladmin -u wikidb_user -p create wikidb
docker-compose run mariadb mysql -u wikidb_user -p wikidb < dump_of_wikidb.sql
</pre>

####Mediawiki Snippets
- MediaWikiServices::getInstance()->getParser()->getFreshParser()

####Transclusion
{{:{{{1}}}}}

####Inline query creator of
<pre>
{{#arraymaptemplate:{{#ask:
 [[Maker::{{PAGENAME}}]]
}}|UnorderedListView|,|\n}}
</pre>

####Form als default Edit: In Kategorieseite
{{#default_form:Work}}