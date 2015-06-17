<?php

class Logger
{
    public static $logPrefix = '';
    public static $logEnabled = true;

    ///////////////
    ///// LOG

    public static function log($o, $force = false, $pre = false, $exit = false)
    {
        if(!self::$logEnabled && !$force) return;
        if(self::$logEnabled && $pre)
        {
            echo "<pre>"; print_r($o); echo "</pre>";
            if($exit) exit;
            return;
        }

        if(is_string($o))
        {
            error_log(self::$logPrefix . $o);
        }
        else
        {
            ob_start();
            print_r($o);
            $contents = ob_get_contents();
            ob_end_clean();
            error_log(self::$logPrefix . $contents);
        }

        if($exit) exit;
    }

}