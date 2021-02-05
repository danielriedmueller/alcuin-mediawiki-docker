Alcuin
===============
## Installation
<pre>
docker-compose up --build -d
</pre>
- Konfiguration in der Weboberflaeche (http://localhost:8001/mw-config)
- LocalSettings.php herunterladen und in Projektverzeichnis speichern
- LocalSettings.php anpassen
- Volumes option in docker-compose.yml einkommentieren (- ./LocalSettings.php:/var/www/html/LocalSettings.php)
- Alternativ:
    - docker cp alcuin_mediawiki_1:/var/www/html/. .
    - volumes option: - .:/var/www/html 
- docker-compose down und docker-compose up --build -d
- docker-compose exec mediawiki maintenance/update.php --quick

#### Datenbank Konfiguration
- Server: mariadb
- Datenbank: mediawiki
- root
- root

#### Mediawiki Konfiguration
- admin
- adminpassword

#### LocalSettings.php Anpassungen
<pre>
wfLoadSkin( 'chameleon' );
$wgDefaultSkin = "chameleon";
wfLoadExtension( 'Bootstrap' );
# The following skins were automatically enabled:

wfLoadExtension( 'ParserFunctions' );
wfLoadExtension( 'Alcuin' );
wfLoadExtension( 'DisplayTitle' );
wfLoadExtension( 'Elastica' );
wfLoadExtension( 'PageForms' );
wfLoadExtension( 'PageSchemas' );
wfLoadExtension( 'CirrusSearch' );
wfLoadExtension( 'Network' );
wfLoadExtension( 'SemanticCite' );
wfLoadExtension( 'Maps' );
wfLoadExtension( 'Variables' );

# End of automatically generated settings.
# Add more configuration options below.
enableSemantics();

$egChameleonLayoutFile= __DIR__ . '/extensions/Alcuin/chameleon/layouts/clean.xml';
$egChameleonExternalStyleModules = [
    __DIR__ . '/extensions/Alcuin/resources/scss/after_main.scss' => 'afterMain'
];
$egChameleonExternalStyleVariables = [
    'container-max-widths' => '(sm: 540px, md: 720px, lg: 960px, xl: 1920px)'
];

require_once "$IP/extensions/SemanticDrilldown/SemanticDrilldown.php";

$wgRestrictDisplayTitle = false;
$wgPageFormsUseDisplayTitle = true;

$wgSearchType = 'CirrusSearch';
$wgDisableSearchUpdate = false;
$wgCirrusSearchServers = [ 'elasticsearch' ];
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

// Exclude Property NS
$wgPageNetworkExcludedNamespaces = [102];
$wgPageNetworkExcludeCategories = ['Event'];

// Supported shapes: "ellipse", "box", "circle", "database", "diamond", "dot", "square", "star", "text", "triangle", "triangleDown", "hexagon"
$wgPageNetworkCategoriesOption = [
    'Work' => [
        'shape' => 'box',
        'color' => '#e63946'
    ],
    'Person' => [
        'shape' => 'ellipse',
        'color' => '#f1faee'
    ],
    'Edition' => [
        'shape' => 'hexagon',
        'color' => '#a8dadc'
    ],
    'Manifestation' => [
        'shape' => 'diamond',
        'color' => '#1d3557'
    ]
];
$egMapsDefaultService = 'leaflet';
</pre>

#### Turtle import with ontology2smw
- git clone https://github.com/TIBHannover/ontology2smw.git
- cd ontology2smw
- pip install --upgrade setuptools
- python setup.py install
- http://localhost:8001/index.php/Special:UserRights -> admin user, add bot to user group
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

#### Elasticsearch einrichten
<pre>
wfLoadExtension( 'CirrusSearch' );
wfLoadExtension( 'Elastica' );

# Konfiguration
$wgSearchType = 'CirrusSearch';
$wgDisableSearchUpdate = false;
$wgCirrusSearchServers = [ 'elasticsearch' ];
$wgCirrusSearchUseCompletionSuggester = 'yes';
$wgCirrusSearchIndexBaseName = 'mediawiki';

# Installs the dependencies for Elastica
docker-compose exec mediawiki composer --working-dir=/var/www/html/extensions/Elastica install 
# Configure the search index and populate it with content
docker-compose exec mediawiki php extensions/CirrusSearch/maintenance/UpdateSearchIndexConfig.php
docker-compose exec mediawiki php extensions/CirrusSearch/maintenance/ForceSearchIndex.php --skipLinks --indexOnSkip
docker-compose exec mediawiki php extensions/CirrusSearch/maintenance/ForceSearchIndex.php --skipParse
# Process the job queue. You need to do this any time you add/update content and want it updated in ElasticSearch
docker-compose exec mediawiki php maintenance/runJobs.php
docker-compose exec mediawiki php extensions/CirrusSearch/maintenance/UpdateSuggesterIndex.php

</pre>

#### Elastic search vm memory
- pactl load-module module-detect
- sysctl -w vm.max_map_count=262144

#### Extensions bearbeiten
- docker cp alcuin_mediawiki_1:/var/www/html/extensions extensions/
- docker cp alcuin_mediawiki_1:/var/www/html/. .


composer config minimum-stability dev

#### PageForms bugfix 
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

#### XML Parser
- sudo apt install python3-bs4 
- sudo apt install python3-pip
- pip install lxml

Page "Utrum_contradictio_sit_maxima_oppositio	" was not imported because the name to which it would be imported is invalid on this wiki.

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
docker-compose run mariadb mysql -u create -p mediawiki < dump_of_wikidb.sql
</pre>

#### Mediawiki Snippets
- MediaWikiServices::getInstance()->getParser()->getFreshParser()

#### Transclusion
{{:{{{1}}}}}

#### Inline query creator of
<pre>
{{#arraymaptemplate:{{#ask:
 [[Maker::{{PAGENAME}}]]
}}|UnorderedListView|,|\n}}
</pre>

{{#ask:
[[Creator::{{PAGENAME}}]]
|?SubjectOf
|?SubjectOf.PartOf
|?SubjectOf.Creator
|format=template
|template=WorkQueryResult
|link=none
}}

Try to use

|link=none
(see source 1)

this will pass {{{1}}} and {{{2}}} results as raw text to your template

You request becomes :

{{#ask: [[Has citekey::someauthor2019]]
|?Has reference
|format=template
|template=Query Result
|link=none
}}
Then you can use {{{1}}} and {{{2}}} as parameters for a new query.

But, you said that you may have multiple results for the {{{has reference}}} result parameter. So you should use something like an arraymaptemplate (see source 2).

{{#arraymaptemplate:value|template|delimiter|new_delimiter}}
where 'template' will use each value of the {{{2}}} list in its own request.

### Subquery mit Person -> Work-> Edition -> Druck -> Reprint
<ul>
{{#arraymap:{{#ask:[[Creator::{{PAGENAME}}]]|?=#}}|,|x0|<li>Werk: [[x0]]
    <ul>
    {{#arraymap:{{#ask:[[IsEditionOf::x0]]|?=#}}|,|x1|<li>Edition: [[x1]]
        <ul>
        {{#arraymap:{{#ask:[[IsPrintOf::x1]]|?=#}}|,|x2|<li>Druck: [[x2]]
            <ul>
            {{#arraymap:{{#ask:[[IsReprintOf::x2]]|?=#}}|,|x3|<li>RePrint: [[x3]]</li>}}
            </ul>|}}</li>
        </ul></li>|}}
    </ul></li>|}}
</ul>

#### Form als default Edit: In Kategorieseite
{{#default_form:Work}}


#### SPARQL
$smwgDefaultStore = 'SMWSparqlStore';
<pre>
docker-compose exec mediawiki php extension/SemanticMediaWiki/maintenance/rebuildData.php -v
</pre>

### Templates anpassen:
{{DISPLAYTITLE:{{{Title}}}}} bei Work, Edition, CommentAristotle, WorkPart

### Nework with Work and Editions
{{#network:
{{#ask:
[[Creator::{{PAGENAME}}]]
|?=#
|?HasEdition=#
|format=array
|link=none
}}
}}

<tr>
<th>Titel</th>
<th>Übersetzer</th>
<th>Editoren</th>
<th>Manuskripte</th>
<th>Drucke</th>
<th>RePrints</th>
</tr>
<tr>