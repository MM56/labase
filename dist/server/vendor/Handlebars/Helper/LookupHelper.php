<?php

namespace Handlebars\Helper;

use Handlebars\Context;
use Handlebars\Helper;
use Handlebars\Template;

class LookupHelper implements Helper
{
    public function execute(Template $template, Context $context, $args, $source)
    {
        $buffer = '';

        $tmp = explode(' ', $args);
        if(count($tmp) == 2)
        {
            $index = $context->get($tmp[1]);
            $buffer = $tmp[0].'.'.$index;
        }

        return $buffer;
    }
}
