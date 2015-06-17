<?php

require_once dirname(__FILE__) . '/server/App.php';

$serverName = $_SERVER["SERVER_NAME"];

$modulesRoutesFile = dirname(__FILE__) . "/datas/modules_routes.json";
$javascriptsFile = dirname(__FILE__) . "/datas/javascripts.json";
// $modulesRoutesFile = dirname(__FILE__) . "/datas/modules_routes.sample.json";
$layoutsFolder = dirname(__FILE__) . "/tpl/layouts";
$partialsFolder = dirname(__FILE__) . "/tpl/partials";
$buildInfoFile = dirname(__FILE__) . "/datas/buildInfo.json";
$buildInfo = App::getArrayContentFrom($buildInfoFile);
$confFile = dirname(__FILE__) . "/conf/" . $buildInfo["env"] . ".casted5.json";
$conf = App::getArrayContentFrom($confFile);

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
	"domain" => $domain
);

switch($serverName) {
	case "labase.local.com":
		$basePath = "/";
		break;
	default:
		$basePath = "/";
		break;
}

$appConfig = array(
	"baseURL" => $baseURL,
	"basePath" => $basePath,
	"currentURL" => $currentURL,
	"locales" => array("fr"),
	"modulesRoutesFile" => $modulesRoutesFile,
	"layoutsFolder" => $layoutsFolder,
	"partialsFolder" => $partialsFolder,
	"javascriptsFile" => $javascriptsFile,
	"env" => $buildInfo["env"],
	"extraDatas" => $extraDatas
);

$app = new App($appConfig);
echo $app->render();

?>
