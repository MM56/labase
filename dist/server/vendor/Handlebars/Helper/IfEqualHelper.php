<?php

namespace Handlebars\Helper;

use Handlebars\Context;
use Handlebars\Helper;
use Handlebars\Template;

class IfEqualHelper implements Helper
{
	/**
	 * Execute the helper
	 *
	 * @param \Handlebars\Template $template The template instance
	 * @param \Handlebars\Context  $context  The current context
	 * @param array                $args     The arguments passed the the helper
	 * @param string               $source   The source
	 *
	 * @return mixed
	 */

	public function execute(Template $template, Context $context, $args, $source)
	{
		$parsedArgs = $template->parseArguments($args);
		if (empty($parsed_args) || count($parsed_args) < 2) {
			return '';
		}

		$condition = ($context->get($parsed_args[0]) == $context->get($parsed_args[1]));
		if ($condition) {
			$template->setStopToken('else');
			$buffer = $template->render($context);
			$template->setStopToken(false);
		} else {
			$template->setStopToken('else');
			$template->discard();
			$template->setStopToken(false);
			$buffer = $template->render($context);
		}

		return $buffer;
	}
}
