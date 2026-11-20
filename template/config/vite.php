<?php
/**
 * craft-vite (nystudio107/craft-vite) settings, all from env.
 *
 * Dev (compose.dev.yml): Craft pings VITE_DEV_SERVER_INTERNAL and uses the
 * dev server when the `vite` profile is up, otherwise the built manifest.
 * Production (compose.yml): always the manifest baked into the image.
 */

use craft\helpers\App;

$dev = App::env('CRAFT_ENVIRONMENT') === 'dev';

return [
    'useDevServer' => $dev,
    'checkDevServer' => $dev,
    'manifestPath' => App::env('VITE_MANIFEST'),
    'serverPublic' => App::env('VITE_SERVER_PUBLIC'),
    'devServerPublic' => App::env('VITE_DEV_SERVER_PUBLIC'),
    'devServerInternal' => App::env('VITE_DEV_SERVER_INTERNAL'),
    'errorEntry' => App::env('VITE_ERROR_ENTRY'),
];
