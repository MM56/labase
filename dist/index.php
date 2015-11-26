<?php

require_once dirname(__FILE__) . '/server/App.php';

$serverName = $_SERVER["SERVER_NAME"];

$modulesRoutesFile = dirname(__FILE__) . "/shared/datas/modules_routes.json";
$javascriptsFile = dirname(__FILE__) . "/shared/datas/javascripts.json";
// $modulesRoutesFile = dirname(__FILE__) . "/datas/modules_routes.sample.json";
$layoutsFolder = dirname(__FILE__) . "/shared/tpl/layouts";
$partialsFolder = dirname(__FILE__) . "/shared/tpl/partials";
$buildInfoFile = dirname(__FILE__) . "/shared/datas/buildInfo.json";
$buildInfo = App::getArrayContentFrom($buildInfoFile);
$confFile = dirname(__FILE__) . "/shared/conf/" . $buildInfo["env"] . ".casted5.json";
$conf = App::getArrayContentFrom($confFile);
$svgFile = dirname(__FILE__) . "/shared/datas/" . "svgs.json";
$svg = App::getArrayContentFrom($svgFile);
$svg_encoded = json_encode($svg);

$baseURL = "http";
if (isset($_SERVER["HTTPS"]) && $_SERVER["HTTPS"] == "on") $baseURL .= "s";
$baseURL .= "://" . $_SERVER["HTTP_HOST"];

$currentURL = "http";
if (isset($_SERVER["HTTPS"]) && $_SERVER["HTTPS"] == "on") $currentURL .= "s";
$currentURL .= "://" . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'];

function getDomain($host) {
	$hostParts = explode(".", $host);
	if(count($hostParts) <= 2) {
		return $host;
	}
	array_shift($hostParts);
	return implode(".", $hostParts);
}

$domain = getDomain($_SERVER["HTTP_HOST"]);
$extraDatas = array(
	"domain" => $domain,
	"svg" => $svg,
	"svg_encoded" => $svg_encoded
);

if(array_key_exists("debug", $_GET) && $buildInfo["env"] != "prod") {
	$extraDatas["debugMode"] = true;
}

$appConfig = array(
	"baseURL" => $baseURL,
	"basePath" => $conf["basePath"],
	"currentURL" => $currentURL,
	"locales" => array("en"),
	"modulesRoutesFile" => $modulesRoutesFile,
	"layoutsFolder" => $layoutsFolder,
	"partialsFolder" => $partialsFolder,
	"javascriptsFile" => $javascriptsFile,
	"env" => $buildInfo["env"],
	"assetsBaseURL" => $conf["assetsBaseURL"],
	"assetsPath" => $buildInfo["assetsPath"],
	"l10nFile" => "{{basePath}}shared/datas/l10n/{{locale}}.json",
	"manifestFile" => "{{basePath}}shared/datas/manifest.json",
	"extraDatas" => $extraDatas
);

$app = new App($appConfig);
echo $app->render();

?>
