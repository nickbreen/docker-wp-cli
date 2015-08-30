<?php

$RE = <<<'ERE'
/
(?P<media>[^\/]+)
\/
(?:(?P<tree>.+)\.)?
(?P<subtype>[^;+]+)
(?:\+(?P<suffix>[^;]+))?
(?P<parameters_scalar>
  (?: #P<parameter>
    ;[ ]
    (?: #P<pname>
      [^=]+)
    (?:=(?: #P<pvalue>
      [^;]*))?
  )*
)
/x
ERE;

$PRE = <<<'ERE'
/
;[ ]
(?P<pname>[^=]+)
(?:=(?P<pvalue>[^;]*))?
/x
ERE;

$opts = getopt('v', array('key:','secret:','url:'));

try {
  $oauth = new OAuth($opts['key'], $opts['secret']);

  $oauth->fetch($opts['url']);

  $response_info = $oauth->getLastResponseInfo();

  if (isset($opts['v']))
    error_log(print_r($response_info, TRUE));

  // parse the content-type header
  $mime_type = (object) $response_info['content_type'];
  preg_match($RE, $response_info['content_type'], $m);
  foreach ($m as $i => $v)
    if (is_string($i))
      $mime_type->$i = $v;

  preg_match_all($PRE, $mime_type->parameters_scalar, $pm,  PREG_SET_ORDER);
  foreach ($pm as $x => $pa)
    $mime_type->parameters[$pa['pname']] = $pa['pvalue'];

  if (!posix_isatty(STDOUT) || $mime_type->media == 'text' || $mime_type->subtype == 'json' || $mime_type->suffix == 'json')
    print $oauth->getLastResponse();
  else
    error_log("Cowardly refusing to output the repsonse entity to a terminal." . PHP_EOL . print_r($mime_type, TRUE));
} catch (OAuthException $e) {
  error_log($e->getMessage());
  exit(1);
}
