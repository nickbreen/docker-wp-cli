<?php

$opts = getopt('v', array('key:','secret:','url:'));

$oauth = new OAuth($opts['key'], $opts['secret']);

$oauth->fetch($opts['url']);

$response_info = $oauth->getLastResponseInfo();

if (isset($opts['v']))
  error_log(print_r($response_info, TRUE));

if (posix_isatty(STDOUT) && !preg_match('/text\/\w+;/', $response_info['content_type']))
  error_log("Cowardly refusing to output a non-text repsonse entity to terminal.");
else
  print $oauth->getLastResponse();
