<?php

/**
 * This file is part of Handlebars-php
 * Base on mustache-php https://github.com/bobthecow/mustache.php
 *
 * PHP version 5.3
 *
 * @category  Xamin
 * @package   Handlebars
 * @author    fzerorubigd <fzerorubigd@gmail.com>
 * @author    Behrooz Shabani <everplays@gmail.com>
 * @author    Craig Bass <craig@clearbooks.co.uk>
 * @author    ^^         <craig@devls.co.uk>
 * @copyright 2010-2012 (c) Justin Hileman
 * @copyright 2012 (c) ParsPooyesh Co
 * @copyright 2013 (c) Behrooz Shabani
 * @license   MIT <http://opensource.org/licenses/MIT>
 * @version   GIT: $Id$
 * @link      http://xamin.ir
 */

namespace Handlebars\Loader;

use Handlebars\Loader;
use Handlebars\String;

/**
 * Handlebars Template filesystem Loader implementation.
 *
 * @category  Xamin
 * @package   Handlebars
 * @author    fzerorubigd <fzerorubigd@gmail.com>
 * @copyright 2010-2012 (c) Justin Hileman
 * @copyright 2012 (c) ParsPooyesh Co
 * @license   MIT <http://opensource.org/licenses/MIT>
 * @version   Release: @package_version@
 * @link      http://xamin.ir *
 */

class AliasIterableLoader extends FilesystemLoader implements Loader
{
    private $_aliases;
    private $_currentModuleId;

    /**
     * Handlebars filesystem Loader constructor.
     *
     * $options array allows overriding certain Loader options during instantiation:
     *
     *     $options = array(
     *         // extension used for Handlebars templates. Defaults to '.handlebars'
     *         'extension' => '.other',
     *     );
     *
     * @param string|array $baseDirs A path contain template files or array of paths
     * @param array        $options  Array of Loader options (default: array())
     *
     * @throws \RuntimeException if $baseDir does not exist.
     */
    public function __construct($baseDirs, array $aliases = array(), array $options = array())
    {
        $this->setAliases($aliases);
        parent::__construct($baseDirs, $options);
    }

    /**
     * Load a Template by name.
     *
     *     $loader = new FilesystemLoader(dirname(__FILE__).'/views');
     *     // loads "./views/admin/dashboard.handlebars";
     *     $loader->load('admin/dashboard');
     *
     * @param string $name template name
     *
     * @return String Handlebars Template source
     */
    public function load($name)
    {
        if (array_key_exists($name, $this->_aliases) && count($this->_aliases[$name]) > 0 && count($this->_aliases[$name]) > $this->_currentModuleId) {
            $name = $this->_aliases[$name][$this->_currentModuleId];
            $this->_currentModuleId++;
            if(is_array($name)) {
                $partials = array();
                foreach($name as $partialName) {
                    array_push($partials, parent::load($partialName));
                }
                return implode("", $partials);
            }
        }
        return parent::load($name);
    }

    /**
     * Set an associative array of Template aliases for this loader.
     *
     * @param array $aliases
     */
    public function setAliases(array $aliases)
    {
        // $this->aliases = $aliases;
        $this->_aliases = array();
        foreach($aliases as $name => $modulesArray) {
            $this->_aliases[$name] = $modulesArray;
        }
        $this->_currentModuleId = 0;
    }

    /**
     * Set a Template alias by name.
     *
     * @param string $name
     * @param string $alias Mustache Template alias
     */
    public function setAlias($name, $alias)
    {
        $this->_aliases[$name] = $alias;
    }

}
