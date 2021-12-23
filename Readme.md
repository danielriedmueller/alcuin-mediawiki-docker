Alcuin
===============
## Installation
In docker-compose.yml Benutzername und Passwort fuer mariadb vergeben
Verzeichnis databases/fuseki muss vorhanden und beschreibbar sein  - sudo chmod -R 777 databases/
<pre>
docker-compose up --build -d
</pre>
- Konfiguration in der Weboberflaeche (http://localhost:8001/mw-config)
- LocalSettings.php herunterladen und in Projektverzeichnis speichern
- LocalSettings.php anpassen (inkl. richtiger host in enableSemantics)
- Volumes option in docker-compose.yml einkommentieren (- ./LocalSettings.php:/var/www/html/LocalSettings.php)
- Alternativ:
    - docker cp alcuin_mediawiki_1:/var/www/html/. .
    - volumes option: - .:/var/www/html 
- docker-compose down und docker-compose up --build -d
- docker-compose exec mediawiki bash
- php maintenance/update.php --quick
- cd extension/LinkedWiki
  - nano extension.json, delete "resources/bootstrap/dist/bootstrap.light.min.css"
  - ggf. composer install und yarn install
    - wenn Node Version zu gering ist: https://phoenixnap.com/kb/update-node-js-version
- cd extension/ModernTimeline
  - composer install
  
#### Datenbank Konfiguration
- Server: mariadb
- Datenbank: mediawiki

#### LocalSettings.php Anpassungen
<pre>
wfLoadSkin( 'chameleon' );
$wgDefaultSkin = "chameleon";

wfLoadExtension( 'DisplayTitle' );
wfLoadExtension( 'LinkedWiki' );
wfLoadExtension( 'Bootstrap' );
wfLoadExtension( 'ParserFunctions' );
wfLoadExtension( 'Alcuin' );
wfLoadExtension( 'PageForms' );
wfLoadExtension( 'PageSchemas' );
wfLoadExtension( 'SemanticFormsSelect' );
wfLoadExtension( 'Network' );
wfLoadExtension( 'SemanticCite' );
wfLoadExtension( 'Maps' );
wfLoadExtension( 'Variables' );
wfLoadExtension( 'SemanticResultFormats' );
wfLoadExtension( 'Tabs' );
wfLoadExtension( 'ExternalData' );
wfLoadExtension( 'ApprovedRevs' );
wfLoadExtension( 'ModernTimeline' );
wfLoadExtension( 'UrlGetParameters' );
wfLoadExtension( 'HeaderTabs' );

#Mit verwendeten Host ersetzen
enableSemantics('alcuin.soital.de');

$egChameleonLayoutFile= __DIR__ . '/extensions/Alcuin/chameleon/layouts/clean.xml';
$egChameleonExternalStyleModules = [
    __DIR__ . '/extensions/Alcuin/resources/scss/style.scss' => 'afterMain',
    __DIR__ . '/extensions/Alcuin/resources/scss/variables.scss' => 'afterVariables',
];
$egChameleonExternalStyleVariables = [
    'container-max-widths' => '(sm: 540px, md: 720px, lg: 960px, xl: 1920px)'
];

require_once "$IP/extensions/SemanticDrilldown/SemanticDrilldown.php";

$wgAllowDisplayTitle = true;
$wgRestrictDisplayTitle = false;
$wgPageFormsUseDisplayTitle = false;

$smwgMainCacheType=CACHE_NONE;
$smwgCacheType=CACHE_NONE;
$smwgQueryResultCacheType=CACHE_NONE;
$wgParserCacheType=CACHE_NONE;
$wgEnableParserCache = false;
$wgCachePages = false;

$wgShowExceptionDetails = false;
$wgShowDBErrorBacktrace = false;

$wgGroupPermissions['user']['generatepages'] = true;
$wgGroupPermissions['*']['edit'] = false;
$wgGroupPermissions['*']['createpage'] = false;
$wgGroupPermissions['admin']['edit'] = true;
$wgGroupPermissions['admin']['createpage'] = true;
$wgGroupPermissions['admin']['smw-admin'] = true;
$wgGroupPermissions['admin']['smw-pageedit'] = true;
$wgGroupPermissions['admin']['smw-patternedit'] = true;
$wgGroupPermissions['admin']['smw-schemaedit'] = true;
$wgGroupPermissions['user']['approverevisions'] = true;

$egScssCacheType = CACHE_NONE;
$wgPageFormsFormCacheType = CACHE_NONE;
$wgInvalidateCacheOnLocalSettingsChange = true;
$smwgChangePropagationProtection = false;

// Exclude Property NS
$wgPageNetworkExcludedNamespaces = [102];
$wgPageNetworkExcludeCategories = ['Event','WorkAuthorshipReference'];

// Supported shapes: "ellipse", "box", "circle", "database", "diamond", "dot", "square", "star", "text", "triangle", "triangleDown", "hexagon"
$wgPageNetworkCategoriesOption = [
    'Work' => [
        'shape' => 'box',
        'color' => '#e63946'
    ],
    'Person' => [
        'shape' => 'ellipse',
        'color' => '#ec6200'
    ],
    'EditedText' => [
        'shape' => 'hexagon',
        'color' => '#a8dadc'
    ],
    'Manifestation' => [
        'shape' => 'diamond',
        'color' => '#1d3557'
    ]
];
$egMapsDefaultService = 'leaflet';

$srfgArraySep = "|";
$srfgArrayPropSep  = "|";
$srfgArrayManySep  = "|";

$wgPFEnableStringFunctions = true;
$wgPageFormsLinkAllRedLinksToForms = true;

$smwgDefaultStore = 'SMWSparqlStore';
$smwgSparqlRepositoryConnector = 'fuseki';
$smwgSparqlQueryEndpoint = 'fuseki:3030/fuseki/query';
$smwgSparqlUpdateEndpoint = 'fuseki:3030/fuseki/update';
$smwgSparqlDataEndpoint = '';

#Mit verwendeten Host ersetzen
$wgLinkedWikiConfigSPARQLServices["fuseki"] = array(
	"debug" => false,
        "isReadOnly" => false,
        "typeRDFDatabase" => "fuseki",
        "endpointRead" => "http://alcuin.soital.de:3030/fuseki/sparql",
        "endpointWrite" => "http://alcuin.soital.de:3030/fuseki/update",
        "HTTPMethodForRead" => "GET",
        "HTTPMethodForWrite" => "POST",
);

$wgLinkedWikiSPARQLServiceByDefault= "fuseki";
$wgLinkedWikiSPARQLServiceSaveDataOfWiki= "fuseki";

$wgMemoryLimit = "1G";
$wgAllowExternalImages = true;
$wgDisplayTitleHideSubtitle = true;
$egApprovedRevsAutomaticApprovals = false;
$smwgQMaxInlineLimit = 5000;
$edgExternalValueVerbose = false;
$wgExternalLinkTarget = '_blank';
$wgShowExceptionDetails = true; 
$srfgMapProvider='OpenStreetMap.HOT';
$wgDefaultUserOptions ['editsection'] = false;
</pre>

### Linked Wiki Anpassung
<pre>
remove: extension.json:163 "resources/bootstrap/dist/bootstrap.light.min.css"
</pre>

#### Turtle import with ontology2smw
- git clone https://github.com/TIBHannover/ontology2smw.git
- cd ontology2smw
- pip install --upgrade setuptools
- python setup.py install
- http://localhost:8001/index.php?title=Special:UserRights&user=admin -> add bot to user group
- http://localhost:8001/index.php/Special:BotPasswords -> insert bot name (e.g. ontology), grant basic, editinterface, editpage, editprotected, createeditmovepage, highvolume, generate bot password
- add password to ontology2swm/wikidetails.yml
    - e.g. 
    <pre>
    host: localhost:8001
    path: /
    scheme: http
    username: Admin@ontology # bot username
    password: j2mkt18rjlnj8rhuqq3gt17km8q1sn7s
    </pre>
- in LocalSettings.php: $smwgChangePropagationProtection = true;
- in ontology2smw directory
  - for test dry run: ontology2smw --format ttl --ontology http://purl.org/spar/fabio.ttl
  - for actual writing data: ontology2smw --format ttl --ontology <TURTLE_FILE>.ttl --write

#### XML import with rdf2smw
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
php maintenance/runJobs.php
</pre>

### Fuseki
Verzeichnis databases/fuseki muss vorhanden sein
sudo chmod -R 777 databases/

#### XML Parser
- sudo apt install python3-bs4 
- sudo apt install python3-pip
- pip install lxml

#### Datenbank Dump
<pre>
docker-compose exec mariadb mysqldump --default-character-set=binary --user=root --password=root mediawiki > dump_of_wikidb.sql
docker-compose exec mariadb mysqladmin -u root -p drop mediawiki
docker-compose exec mariadb mysqladmin -u root -p create mediawiki
</pre>

#### Rebuild DB
<pre>
docker-compose exec mariadb mysqladmin -u root -p drop mediawiki
docker-compose exec mariadb mysqladmin -u root -p create mediawiki
docker-compose exec -T mariadb mysql -uroot -proot mediawiki < dump_of_wikidb.sql
</pre>

#### Transclusion
{{:{{{1}}}}}

#### Form als default Edit: In Kategorieseite
{{#default_form:Work}}

#### Damit Templates nicht in Kategorien auftauchen. In template seite:
<includeonly>[[Category:unfinished]]</includeonly>

#### SPARQL
$smwgDefaultStore = 'SMWSparqlStore';
<pre>
docker-compose exec mediawiki php extension/SemanticMediaWiki/maintenance/rebuildData.php -v
</pre>
