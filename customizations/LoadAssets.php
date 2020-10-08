<?php

$wgResourceModules['zzz.customizations'] = array(
    // 'styles' => "skin.css", // Stylesheet to be loaded in all skins
    // Custom styles to apply only to Vector skin. Remove if you don't use it
    'skinStyles' => array(
        'chameleon' => 'css/skin-chameleon.css',
    ),
    // End custom styles for vector
    'scripts' => "js/skin.js", // Script file to be loaded in all skins
    'localBasePath' => "$IP/customizations/",
    'remoteBasePath' => "$wgScriptPath/customizations/"
);

function efCustomBeforePageDisplay( &$out, &$skin ) {
    $out->addModules( array( 'zzz.customizations' ) );
}

$wgHooks['BeforePageDisplay'][] = 'efCustomBeforePageDisplay';
