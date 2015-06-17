<?php

require_once dirname(__FILE__) . '/Module.php';
require_once dirname(__FILE__) . '/vendor/PathToRegexp.php';
require_once dirname(__FILE__) . '/vendor/Mobile_Detect.php';
require_once dirname(__FILE__) . '/vendor/Logger.php';

class App {

	protected $config = array(
		"locales" => array("en"),
		"baseURL" => "",
		"currentURL" => "",
		"basePath" => "/",
		"l10nFile" => "/datas/l10n/{{locale}}.json",
		"modulesRoutesFile" => "/datas/modules_routes.json",
		"javascriptsFile" => "{{basePath}}datas/javascripts.json",
		"layoutsFolder" => "{{basePath}}tpl/layouts",
		"partialsFolder" => "{{basePath}}tpl/partials",
		"defaultLayoutName" => "default",
		"compileTemplates" => false,
		"env" => "dev",
		"extraDatas" => array(),
		"forceMobileRedirect" => "mobile"
	);
	protected $currentLocale;
	protected $l10n;
	protected $content;
	protected $detect;
	protected $requestURI;
	protected $noLocaleInRoute;


	public function __construct(array $configOptions = array()) {
		$this->detect = new Mobile_Detect();
		if($this->detect->is("bot")) {
			$this->config["compileTemplates"] = true;
		}

		// parse config
		foreach($configOptions as $configOptionName => $configOption) {
			if(array_key_exists($configOptionName, $this->config)) {
				$this->config[$configOptionName] = $configOption;
			}
		}
	}

	public function render() {
		$this->init();

		$route = $this->requestURI;
		$moduleRequested = $this->getModuleByRoute($route, $this->modulesList);
		$this->cleanModuleTree($moduleRequested, $moduleRequested);

		$rootModule = $this->getRootModuleFrom($moduleRequested);

		if($this->config["compileTemplates"]) {
			$flattenTree = $this->getFlattenTreeFrom($rootModule);
			$partialsLoader = new Handlebars\Loader\AliasIterableLoader($this->config["partialsFolder"], array("modules" => $flattenTree), array("extension" => ".hbs"));
		} else {
			$flattenTree = $this->getModules($rootModule);
			$partialsLoader = new Handlebars\Loader\FilesystemLoader($this->config["partialsFolder"], array("extension" => ".hbs"));

			$defaultTemplates = array();
			foreach($flattenTree as $index => $templateObject) {
				$obj = "\"" . $templateObject["name"] . "\": \"" . str_replace("\n", "\\n", addslashes($partialsLoader->load($templateObject["tpl"]))) . "\"";
				if($index < count($flattenTree) - 1) {
					$obj .= ",";
				}
				array_push($defaultTemplates, $obj);
			}
			$globalContent = $this->content["GLOBAL"];
			$globalContent["defaultTemplates"] = $defaultTemplates;
			$this->content["GLOBAL"] = $globalContent;
		}

		// template engine rendering
		$loader = new Handlebars\Loader\FilesystemLoader($this->config["layoutsFolder"], array("extension" => ".hbs"));
		$tplRenderer = new Handlebars\Handlebars(array(
			"loader" => $loader,
			"partials_loader" => $partialsLoader
		));
		$tplRenderer->addHelper("render", new Handlebars\Helper\RenderHelper());
		return $tplRenderer->render($this->config["defaultLayoutName"], $this->content);
	}

	protected function init() {
		$this->ensureLocale();
		$this->ensurePath();
		$this->initTemplateEngine();
		$this->loadL10n();
		$this->loadModulesRoutes();
		$this->buildModulesList();
		$this->buildContent();
	}

	protected function ensureLocale() {
		if(count($this->config["locales"]) == 1) {
			$this->currentLocale = $this->config["locales"][0];
			$this->noLocaleInRoute = true;
			return;
		}

		$forceLocaleRedirect = false;
		$this->noLocaleInRoute = false;

		// grab requested locale
		if(!empty($_GET["_escaped_fragment_"])) {
			$escapedFragment = $_GET["_escaped_fragment_"];
			if(strpos($escapedFragment, $this->config["basePath"]) === 0) {
				$escapedFragment = substr($escapedFragment, strlen($this->config["basePath"]));
			}
			$this->currentLocale = substr($escapedFragment, 0, 2);
		} else {
			$this->currentLocale = substr($_SERVER['HTTP_ACCEPT_LANGUAGE'], 0, 2);
			$forceLocaleRedirect = true;
		}

		// check if available locale
		if(!in_array($this->currentLocale, $this->config["locales"])) {
			$this->currentLocale = $this->config["locales"][0];
			$forceLocaleRedirect = true;
		}

		// redirect to an available locale if requested is not accepted
		if($forceLocaleRedirect) {
			header("Location: " . $this->config["basePath"] . $this->currentLocale . "/");
			exit();
		}
	}

	protected function ensurePath() {
		if($this->noLocaleInRoute) {
			if(empty($_GET["_escaped_fragment_"]) || $_GET["_escaped_fragment_"] == "/") {
				$this->requestURI = "/";
			} else {
				$escapedFragment = $_GET["_escaped_fragment_"];
				if(strpos($escapedFragment, "/") === 0) {
					$escapedFragment = substr($escapedFragment, 1);
				}
				$this->requestURI = "/" . $escapedFragment;
			}
		} else {
			$requestURI = $_GET["_escaped_fragment_"];
			if(strpos($requestURI, $this->config["basePath"]) === 0) {
				$requestURI = substr($requestURI, strlen($this->config["basePath"]) + 1);
			}
			if(strpos($requestURI, $this->currentLocale) === 0) {
				$requestURI = substr($requestURI, strlen($this->currentLocale) + 1);
			}
			$this->requestURI = $requestURI;
			if(strpos($this->requestURI, "/") !== 0) {
				$this->requestURI = "/" . $this->requestURI;
			}
		}

		/*
		if($this->detect->isPhone() && !empty($this->config["forceMobileRedirect"]) && !preg_match("/(" . $this->currentLocale . "\/)?(" . addslashes($this->config["forceMobileRedirect"]) .")/i", $this->requestURI)) {
			$p = $this->config["basePath"];
			if(!$this->noLocaleInRoute) {
				$p .= $this->currentLocale . "/";
			}
			$p .= $this->config["forceMobileRedirect"];
			header("Location: " . $p);
			exit();
		}
		*/
	}

	protected function redirect($path) {
		if(($this->detect->isTablet() || (!$this->detect->isTablet() && !$this->detect->isMobile()))  && $this->requestURI != $path) {
			header("Location: " . $path);
			exit();
		} elseif($this->detect->isMobile() && !$this->detect->isTablet() && $this->requestURI != "/mobile" . $path) {
			header("Location: /mobile" . $path);
			exit();
		}
	}

	protected function initTemplateEngine() {
		require_once dirname(__FILE__) . '/vendor/Handlebars/Autoloader.php';
		Handlebars\Autoloader::register();
	}

	protected function loadL10n() {
		$tplRenderer = new Handlebars\Handlebars();
		$l10nFilePath = dirname(__FILE__) . "/.." . $tplRenderer->render($this->config["l10nFile"], array(
			"locale" => $this->currentLocale
		));
		$this->l10n = self::getArrayContentFrom($l10nFilePath);
	}

	static public function getArrayContentFrom($jsonFilePath) {
		$content = file_get_contents($jsonFilePath);
		return json_decode($content, true);
	}

	protected function loadModulesRoutes() {
		$tplRenderer = new Handlebars\Handlebars();
		$modulesRoutesFilePath = $tplRenderer->render($this->config["modulesRoutesFile"], array(
			"locale" => $this->currentLocale
		));
		$this->modulesRoutes = self::getArrayContentFrom($modulesRoutesFilePath);
	}

	protected function buildModulesList() {
		Module::$l10n = $this->l10n;
		$this->modulesList = Module::buildModulesList($this->modulesRoutes);
	}

	protected function getJSFiles($JSdatas) {
		$javascripts = $JSdatas["files"];
		$builds = $JSdatas["builds"];
		$build = $this->getBuild();

		$files = array();

		if($this->config["env"] == "dev") {
			$vendors = $javascripts["vendors"];
			foreach($vendors as $vendor) {
				$file = $this->getJSFile($vendor, $build);
				if(!empty($file)) {
					array_push($files, $file);
				}
			}

			$srcs = $javascripts["src"];
			foreach($srcs as $src) {
				$file = $this->getJSFile($src, $build);
				if(!empty($file)) {
					array_push($files, "js/" . $file . ".js");
				}
			}
		} else {
			array_push($files, "js/" . $builds[$build]["vendors"] . ".js");
			array_push($files, "js/" . $builds[$build]["src"] . ".js");
		}

		return $files;
	}

	protected function getBuild() {
		if(!$this->detect->isTablet() && $this->detect->isMobile()) {
			return "mobile";
		}
		return "default";
	}

	protected function getJSFile($fileInput, $build) {
		if(is_array($fileInput)) {
			if(in_array($build, $fileInput["builds"])) {
				return $fileInput["file"];
			} else {
				return NULL;
			}
		} else {
			return $fileInput;
		}
	}

	protected function buildContent() {
		$tplRenderer = new Handlebars\Handlebars();
		$javascriptsFilePath = $tplRenderer->render($this->config["javascriptsFile"], array(
			"locale" => $this->currentLocale
		));
		$javascripts = self::getArrayContentFrom($javascriptsFilePath);
		$scripts = $this->getJSFiles($javascripts);

		$detect = array();
		if($this->detect->isTablet()) {
			$detect["device"] = "tablet";
			$detect["os"] = strtolower($this->detect->os());
			$detect["browser"] = strtolower($this->detect->browser());
		} elseif($this->detect->isMobile()) {
			$detect["device"] = "phone";
			$detect["os"] = strtolower($this->detect->os());
			$detect["browser"] = strtolower($this->detect->browser());
		} else {
			if(strpos($this->config["currentURL"],'/mobile') !== false) {
				$detect["device"] = "nomobile";
			} else {
				$detect["device"] = "desktop";
			}
			if(preg_match('/linux/i', $this->detect->getUserAgent())) {
				$detect["os"] = "linux";
			} elseif(preg_match('/macintosh|mac os x/i', $this->detect->getUserAgent())) {
				$detect["os"] = "mac";
			} elseif(preg_match('/windows|win32/i', $this->detect->getUserAgent())) {
				$detect["os"] = "windows";
			}
			if(!preg_match('/opera|webtv/i', $this->detect->getUserAgent()) && (preg_match('/msie\s(\d*)/i', $this->detect->getUserAgent(), $version) || preg_match("/trident\/.*rv:(\d*)/i", $this->detect->getUserAgent(), $version))) {
				$detect["browser"] = "ie";
				if(count($version) > 1) {
					$detect["browser"] .= " ie" . $version[1];
				}
			} elseif(preg_match('/firefox/i', $this->detect->getUserAgent())) {
				$detect["browser"] = "firefox";
			} elseif(preg_match('/opera/i', $this->detect->getUserAgent())) {
				$detect["browser"] = "opera";
			} elseif(preg_match('/chrome/i', $this->detect->getUserAgent())) {
				$detect["browser"] = "chrome";
			} elseif(preg_match('/safari/i', $this->detect->getUserAgent())) {
				$detect["browser"] = "safari";
			}
		}

		$noLocaleInRoute = $this->noLocaleInRoute ? "true": "false";
		$globalContent = array(
			"baseURL" => $this->config["baseURL"] . $this->config["basePath"],
			"currentURL" => $this->config["currentURL"],
			"locale" => $this->currentLocale,
			"basePath" => $this->config["basePath"],
			"isDesktop" => (($detect["device"] == "desktop" || $detect["device"] == "tablet") && strpos($this->config["currentURL"],'/mobile') === false),
			"isNoMobile" => ($detect["device"] == "desktop" && strpos($this->config["currentURL"],'/mobile') !== false),
			"noLocaleInRoute" => $noLocaleInRoute
		);

		// datas for template engine
		$this->content = array_merge($this->l10n, array(
			"isDev" => $this->config["env"] == "dev",
			"scripts" => $scripts,
			"detect" => $detect,
			"GLOBAL" => $globalContent
		), $this->config["extraDatas"]);

		if($this->config["compileTemplates"]) {
			unset($this->content["scripts"]);
		}
	}

	protected function getModuleByRoute($route, $data) {
		return Module::getModuleByRoute($route, $data);
	}

	protected function cleanModuleTree($module, $moduleExcepted) {
		Module::cleanModuleTree($module, $moduleExcepted);
	}

	protected function getRootModuleFrom($module) {
		return Module::getRootModuleFrom($module);
	}

	protected function getFlattenTreeFrom($rootModule) {
		return Module::getFlattenTreeFrom($rootModule);
	}

	protected function getModules($rootModule) {
		return Module::getModules($rootModule);
	}
}

?>