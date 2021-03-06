<?php

require_once dirname(__FILE__) . '/Module.php';
require_once dirname(__FILE__) . '/vendor/PathToRegexp.php';
require_once dirname(__FILE__) . '/vendor/Mobile_Detect.php';
require_once dirname(__FILE__) . '/vendor/Logger.php';
require_once dirname(__FILE__) . '/vendor/geoplugin.class.php';

class App {

	protected $config = array(
		"locales" => array("en"),
		"env" => "dev",
		"baseURL" => "",
		"basePath" => "/",
		"currentURL" => "",
		"assetsPath" => "",
		"assetsBaseURL" => "/",
		"layoutsFolder" => "",
		"partialsFolder" => "",
		"modulesRoutesFile" => "",
		"javascriptsFile" => "",
		"l10nFile" => "",
		"manifestFile" => "",
		"svgsFile" => "",
		"defaultLayoutName" => "default",
		"compileTemplates" => false,
		"extraDatas" => array(),
		"forceMobileRedirect" => "mobile"
	);

	protected $currentLocale;
	protected $l10n;
	protected $content;
	protected $detect;
	protected $requestURI;
	protected $noLocaleInRoute;
	protected $forceLocaleRedirect;
	protected $layout;

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
		$this->layout = $this->config["defaultLayoutName"];
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

		$this->content["header"] = $this->getHeader($route);

		// template engine rendering
		$loader = new Handlebars\Loader\FilesystemLoader($this->config["layoutsFolder"], array("extension" => ".hbs"));
		$tplRenderer = new Handlebars\Handlebars(array(
			"loader" => $loader,
			"partials_loader" => $partialsLoader
		));
		$tplRenderer->addHelper("render", new Handlebars\Helper\RenderHelper());
		$tplRenderer->addHelper("lookup", new Handlebars\Helper\LookupHelper());
		$tplRenderer->addHelper("IfEqual", new Handlebars\Helper\IfEqualHelper());
		return $tplRenderer->render($this->layout, $this->content);
	}

	protected function init() {
		$this->ensureLocale();
		$this->ensurePath();
		$this->initTemplateEngine();
		$this->loadL10n();
		$this->loadSvgs();
		$this->loadManifest();
		$this->loadModulesRoutes();
		$this->buildModulesList();
		$this->buildContent();
	}

	private function getHeader($route)
	{
		$methodGetShareDatas = (isset($_GET['method']) && $_GET['method'] == 'getShareDatas');

		if($methodGetShareDatas && isset($_POST['route']))
			$route = preg_replace('/[^A-Za-z0-9\-\_\/]/', '', $_POST['route']);

		$datas = $this->l10n['HEADER_META'];

		$header = $datas[0];// copy array
		foreach($datas as $data)
		{
			if(isset($data['route']) && $data['route'] == $route)
			{
				if(isset($data['title'])) $header['title'] = $data['title'];
				if(isset($data['desc'])) $header['desc'] = $data['desc'];
				if(isset($data['img'])) $header['img'] = $data['img'];
				if(isset($data['share'])) $header['share'] = $data['share'];
			}
		}
		$header['route'] = $route;
		$header['json'] = json_encode($header);

		if($methodGetShareDatas)
			exit($header['json']);

		return $header;
	}

	protected function ensureLocale() {
		if(count($this->config["locales"]) == 1) {
			$this->currentLocale = $this->config["locales"][0];
			$this->noLocaleInRoute = true;
			return;
		}

		$this->forceLocaleRedirect = false;
		$this->noLocaleInRoute = false;

		// grab requested locale
		if(!empty($_GET["_escaped_fragment_"])) {
			$escapedFragment = $_GET["_escaped_fragment_"];
			if(strpos($escapedFragment, $this->config["basePath"]) === 0) {
				$escapedFragment = substr($escapedFragment, strlen($this->config["basePath"]));
			}
			$this->currentLocale = substr($escapedFragment, 0, 2);
		} else {
			$geoplugin = new geoPlugin();
			$ipaddress = '';
			if (array_key_exists("HTTP_CLIENT_IP", $_SERVER)) {
				$ipaddress = $_SERVER['HTTP_CLIENT_IP'];
			} else if (array_key_exists("HTTP_X_FORWARDED_FOR", $_SERVER)) {
				$ipaddress = $_SERVER['HTTP_X_FORWARDED_FOR'];
			} else if (array_key_exists("HTTP_X_FORWARDED", $_SERVER)) {
				$ipaddress = $_SERVER['HTTP_X_FORWARDED'];
			} else if (array_key_exists("HTTP_FORWARDED_FOR", $_SERVER)) {
				$ipaddress = $_SERVER['HTTP_FORWARDED_FOR'];
			} else if (array_key_exists("HTTP_FORWARDED", $_SERVER)) {
				$ipaddress = $_SERVER['HTTP_FORWARDED'];
			} else if (array_key_exists("REMOTE_ADDR", $_SERVER)) {
				$ipaddress = $_SERVER['REMOTE_ADDR'];
			} else {
				$ipaddress = null;
			}
			$geoplugin->locate($ipaddress);
			$this->currentLocale = strtolower($geoplugin->countryCode);
			$this->forceLocaleRedirect = true;

			if(!in_array($this->currentLocale, $this->config["locales"])) {
				if(array_key_exists("HTTP_ACCEPT_LANGUAGE", $_SERVER)) {
					$this->currentLocale = substr($_SERVER["HTTP_ACCEPT_LANGUAGE"], 0, 2);
					$this->forceLocaleRedirect = true;
				} else {
					$this->currentLocale = $this->config["locales"][0];
				}
				$this->forceLocaleRedirect = true;
			}
		}

		// check if available locale
		if(!in_array($this->currentLocale, $this->config["locales"])) {
			$this->currentLocale = $this->config["locales"][0];
			$this->forceLocaleRedirect = true;
		}

		// redirect to an available locale if requested is not accepted
		if($this->forceLocaleRedirect) {
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

		if(($this->detect->isTablet() || $this->detect->isMobile()) && !empty($this->config["forceMobileRedirect"]) && !preg_match("/(" . $this->currentLocale . "\/)?(" . addslashes($this->config["forceMobileRedirect"]) .")/i", $this->requestURI)) {
			$p = $this->config["basePath"];
			if(!$this->noLocaleInRoute) {
				$p .= $this->currentLocale . "/";
			}
			$p .= $this->config["forceMobileRedirect"];
			$p .= $this->requestURI;
			header("Location: " . $p);
			exit();
		}else {
			if(!$this->detect->isTablet() && !$this->detect->isMobile() && strpos($this->requestURI, $this->config["forceMobileRedirect"]) === 1) {
				$this->requestURI = str_replace("/" . $this->config["forceMobileRedirect"] . "/", "", $this->requestURI);
				$p = $this->config["basePath"];
				if(!$this->noLocaleInRoute) {
					$p .= $this->currentLocale . "/";
				}
				$p .= $this->requestURI;
				header("Location: " . $p);
				exit();
			}else {

			}
		}
	}

	protected function initTemplateEngine() {
		require_once dirname(__FILE__) . '/vendor/Handlebars/Autoloader.php';
		Handlebars\Autoloader::register();
	}

	protected function loadManifest() {
		$tplRenderer = new Handlebars\Handlebars();
		$manifestFilePath = $tplRenderer->render($this->config["manifestFile"], array(
			"locale" => $this->currentLocale
		));
		$this->manifest = json_encode(self::getArrayContentFrom($manifestFilePath));
	}

	protected function loadSvgs() {
		$tplRenderer = new Handlebars\Handlebars();
		$svgsFilePath = $tplRenderer->render($this->config["svgsFile"], array());
		$this->svgs = self::getArrayContentFrom($svgsFilePath);
	}

	protected function loadL10n() {
		$tplRenderer = new Handlebars\Handlebars();
		$l10nFilePath = $tplRenderer->render($this->config["l10nFile"], array(
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
		if($this->detect->isTablet() || $this->detect->isMobile()) {
			return "mobile";
		}
		return "desktop";
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

		$oldBrowser = false;

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
			$detect["device"] = "desktop";
			if(preg_match('/linux/i', $this->detect->getUserAgent())) {
				$detect["os"] = "linux";
			} elseif(preg_match('/macintosh|mac os x/i', $this->detect->getUserAgent())) {
				$detect["os"] = "mac";
			} elseif(preg_match('/windows|win32/i', $this->detect->getUserAgent())) {
				$detect["os"] = "windows";
			}
			if(
				!preg_match('/opera|webtv/i', $this->detect->getUserAgent())
				&& (
					preg_match('/edge\/(\d*)/i', $this->detect->getUserAgent(), $version)
					|| preg_match('/msie\s(\d*)/i', $this->detect->getUserAgent(), $version)
					|| preg_match("/trident\/.*rv:(\d*)/i", $this->detect->getUserAgent(), $version)
				)
			) {
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
			} else {
				$detect["browser"] = "";
			}
		}

		$oldBrowser = $this->isOldBrowser($detect["browser"]);

		// old browsers
		if(!$this->config["compileTemplates"]) {
			if(!$this->detect->isTablet() && !$this->detect->isMobile()) {
				if($oldBrowser) {
					if(strpos($this->requestURI, "/old") !== false) {
						$this->layout = "old";
					} else {
						$p = $this->config["basePath"];
						if(!$this->noLocaleInRoute) {
							$p .= $this->currentLocale . "/";
						}
						$p .= "old";
						header("Location: " . $p);
						exit();
					}
				} else {
					if(strpos($this->requestURI, "/old") !== false) {
						$p = $this->config["basePath"];
						if(!$this->noLocaleInRoute) {
							$p .= $this->currentLocale . "/";
						}
						header("Location: " . $p);
						exit();
					}
				}
			}
		}

		$baseURL = $this->config["baseURL"] . $this->config["basePath"];

		$noLocaleInRoute = $this->noLocaleInRoute ? "true": "false";
		$globalContent = array(
			"baseURL" => $baseURL,
			"currentURL" => $this->config["currentURL"],
			"locale" => $this->currentLocale,
			"basePath" => $this->config["basePath"],
			"isDesktop" => $detect["device"] == "desktop"  ? true: false,
			"isTablet" => $detect["device"] == "tablet"  ? true: false,
			"isPhone" => $detect["device"] == "phone"  ? true: false,
			"noLocaleInRoute" => $noLocaleInRoute,
			"assetsPath" => $this->config["assetsPath"],
			"assetsBaseURL" => $this->config["assetsBaseURL"]
		);


		// datas for template engine
		$this->content = array_merge(array(
			"env" => $this->config["env"],
			"l10n" => $this->l10n,
			"l10n_encoded" => json_encode($this->l10n),
			"svgs" => $this->svgs,
			"svgs_encoded" => json_encode($this->svgs),
			"manifest" => $this->manifest,
			"routes" => $this->modulesRoutes,
			"detect" => $detect,
			"scripts" => $scripts,
			"routes" => json_encode($this->modulesRoutes),
			"GLOBAL" => $globalContent
		), $this->config["extraDatas"]);

		if($this->config["compileTemplates"]) {
			unset($this->content["scripts"]);
		}
	}

	protected function isOldBrowser($browser) {
		if(array_key_exists("force", $_GET)) {
			return true;
		}
		switch ($browser) {
			case "firefox":
				if(floatval($this->detect->version("Firefox")) < 42) {
					return true;
				}
				break;
			case "safari":
				if(floatval($this->detect->version("Safari")) < 9) {
					return true;
				}
				break;
			default:

				if(strpos($browser, "ie") === 0) {
					preg_match('!\d+!', $browser, $version);
					if(intval($version[0]) < 11) {
						return true;
					}
				}
				break;
		}
		return false;
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