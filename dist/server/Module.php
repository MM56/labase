<?php

class Module {
	public $parent;
	public $id;
	public $routes;
	public $modules;
	public $keys;
	public $matches;
	public $content;
	public $tplPattern;
	public $folder;

	static public $l10n;

	public static function buildModulesList($modules) {
		return self::buildModulesListIterator($modules);
	}

	protected static function localizeRoutes($routes) {
		$tplRenderer = new Handlebars\Handlebars();
		if(!empty(self::$l10n["routes"])) {
			if(is_array($routes)) {
				foreach($routes as $key => $route) {
					$routes[$key] = $tplRenderer->render($route, self::$l10n["routes"]);
				}
			} else {
				$routes = $tplRenderer->render($routes, self::$l10n["routes"]);
			}
		}
		return $routes;
	}

	protected static function buildModulesListIterator($data, $parent = null) {
		$m = new Module();
		if(!empty($data["id"])) {
			$m->id = $data["id"];
		}
		if(!empty($parent)) {
			$m->parent = $parent;
		}
		if(!empty($data["routes"])) {
			$m->routes = self::localizeRoutes($data["routes"]);
		}
		if(!empty($data["modules"])) {
			$modules = array();
			foreach($data["modules"] as $module) {
				array_push($modules, self::buildModulesListIterator($module, $m));
			}
			$m->modules = $modules;
		}
		if(!empty($data["tplPattern"])) {
			$m->tplPattern = $data["tplPattern"];
		}
		if(!empty($data["folder"])) {
			$folder = $data["folder"];
			if(strpos($folder, "/") != strlen($folder) - 1) {
				$folder .= "/";
			}
			$m->folder = $folder;
		}
		return $m;
	}

	public static function getModuleByRoute($route, $data) {
		foreach($data->modules as $modulesRoutes) {
			if(!empty($modulesRoutes->routes)) {
				if(is_array($modulesRoutes->routes)) {
					foreach($modulesRoutes->routes as $r) {
						$keys = array();
						$regexp = PathToRegexp::convert($r, $keys);
						$matches = PathToRegexp::match($regexp, $route);
						if(!empty($matches)) {
							$modulesRoutes->keys = $keys;
							$modulesRoutes->matches = $matches;
							$content = array();
							for($i = 0; $i < count($keys); $i++) {
								if($i + 1 < count($matches)) {
									$value = $matches[$i + 1];
								} else {
									$value = "";
								}
								$content[$keys[$i]["name"]] = $value;
							}
							$modulesRoutes->content = $content;
							return $modulesRoutes;
						}
					}
				} else {
					$keys = array();
					$regexp = PathToRegexp::convert($modulesRoutes->routes, $keys);
					$matches = PathToRegexp::match($regexp, $route);
					if(!empty($matches)) {
						$modulesRoutes->keys = $keys;
						$modulesRoutes->matches = $matches;
						$content = array();
						for($i = 0; $i < count($keys); $i++) {
							if($i + 1 < count($matches)) {
								$value = $matches[$i + 1];
							} else {
								$value = "";
							}
							$content[$keys[$i]["name"]] = $value;
						}
						$modulesRoutes->content = $content;
						return $modulesRoutes;
					}
				}
			}
			if(!empty($modulesRoutes->modules)) {
				$module = self::getModuleByRoute($route, $modulesRoutes);
				if(!empty($module)) {
					return $module;
				}
			}
		}
		return null;
	}

	public static function cleanModuleTree($module, $moduleExcepted) {
		if(!empty($module->parent)) {
			self::removeRoutedModules($module->parent, $moduleExcepted);
			if(!empty($module->parent->routes)) {
				$module->parent->routes = null;
			}
			self::cleanModuleTree($module->parent, $moduleExcepted);
		}
	}

	protected static function removeRoutedModules($module, $moduleExcepted) {
		if(!empty($module->modules)) {
			$submodules = $module->modules;
			$module->modules = array_filter($submodules, function($m) use($moduleExcepted) {
				if($m == $moduleExcepted) {
					return true;
				}
				if(!empty($m->routes)) {
					return false;
				} else {
					return true;
				}
			});

			foreach($module->modules as $m) {
				self::removeRoutedModules($m, $moduleExcepted);
			}
		}
	}

	public static function getRootModuleFrom($module) {
		if(empty($module->parent)) {
			return $module;
		} else {
			return self::getRootModuleFrom($module->parent);
		}
	}

	public static function getFlattenTreeFrom($rootModule) {
		$flattenTree = array();
		self::getFlattenTreeFromIterator($rootModule, $flattenTree);
		// if(!is_array($flattenTree[0])) {
		// 	$flattenTree = array($flattenTree);
		// }
		return $flattenTree;
	}

	protected static function getFlattenTreeFromIterator($module, &$tree) {
		if(!empty($module->modules)) {
			$modulesIds = array();
			$tplRenderer = new Handlebars\Handlebars();
			foreach($module->modules as $m) {
				// tplPattern is module id by default
				if(!empty($m->tplPattern)) {
					$tpl = $tplRenderer->render($m->tplPattern, $m->content);
				} else {
					$tpl = $m->id;
				}
				if(!empty($m->folder)) {
					$tpl = $m->folder . $tpl;
				}
				array_push($modulesIds, $tpl);
			}
			if(count($modulesIds) == 1) {
				array_push($tree, $modulesIds[0]);
			} else {
				array_push($tree, $modulesIds);
			}

			foreach($module->modules as $m) {
				if(!empty($m->modules)) {
					self::getFlattenTreeFromIterator($m, $tree);
				}
			}
		}
	}

	public static function getModules($rootModule) {
		$modules = array();
		self::getModulesIterator($rootModule, $modules);
		return $modules;
	}

	public static function getModulesIterator($module, &$modules) {
		if(!empty($module->modules)) {
			foreach($module->modules as $m) {
				$moduleData = array("name" => $m->id);
				// tplPattern is module id by default
				if(!empty($m->tplPattern)) {
					$tplRenderer = new Handlebars\Handlebars();
					$moduleData["tpl"] = $tplRenderer->render($m->tplPattern, $m->content);
				} else {
					$moduleData["tpl"] = $m->id;
				}
				if(!empty($m->folder)) {
					$moduleData["tpl"] = $m->folder . $moduleData["tpl"];
				}
				array_push($modules, $moduleData);
				self::getModulesIterator($m, $modules);
			}
		}
	}


}

?>