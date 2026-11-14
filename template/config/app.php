<?php
/**
 * Yii Application Config
 *
 * Mail goes through SMTP whenever SMTP_HOST is set: Mailpit in dev
 * (compose.dev.yml), the real provider in production (compose.yml).
 * This overrides the transport stored in project config.
 */

use craft\helpers\App;
use craft\mail\transportadapters\Smtp;

$config = [
    'id' => App::env('CRAFT_APP_ID') ?: 'CraftCMS',
];

if (App::env('SMTP_HOST')) {
    $config['components']['mailer'] = function () {
        $settings = App::mailSettings();
        $settings->fromEmail = App::env('MAIL_FROM') ?: $settings->fromEmail;
        $settings->transportType = Smtp::class;
        $settings->transportSettings = [
            'host' => App::env('SMTP_HOST'),
            'port' => App::env('SMTP_PORT') ?: '587',
            'useAuthentication' => App::parseBooleanEnv('$SMTP_AUTH') ?? true,
            'username' => App::env('SMTP_USER'),
            'password' => App::env('SMTP_PASSWORD'),
        ];
        return Craft::createObject(App::mailerConfig($settings));
    };
}

return $config;
