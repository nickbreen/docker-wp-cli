<?php

# Usage:
#  oauth.php [-v] [-O] -k <KEY> -s <SECRET> -- <URI>...
#

define('RE', <<<'ERE'
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
ERE
);

define('PRE', <<<'ERE'
/
;[ ]
(?P<pname>[^=]+)
(?:=(?P<pvalue>[^;]*))?
/x
ERE
);

$opts = getopt('vOk:s:');

$x = array_search('--', $argv);
$uris = array_splice($argv, $x ? ++$x : (count($argv) - count($opts)));

try {
  $oauth = new OAuth($opts['k'], $opts['s']);

  foreach ($uris as $uri)
    get($oauth, $uri);

} catch (OAuthException $e) {
  error_log($e->getMessage());
  exit(1);
}

function get($oauth, $uri) {
  global $opts;
  $oauth->fetch($uri);

  if (isset($opts['v']))
    error_log($oauth->getLastResponseHeaders());

  $headers = http_parse_headers($oauth->getLastResponseHeaders());

  $mime_type = parse_content_type_header($headers['Content-Type']);

  $content_disposition = parse_content_disposition_header($headers['Content-Disposition']);
  $filename = $content_disposition['filename'];

  if (isset($opts['O']) && !empty($filename)) {
    print $filename.PHP_EOL;
    file_put_contents($filename, $oauth->getLastResponse());
  } else if (!posix_isatty(STDOUT) || $mime_type->media == 'text' || $mime_type->subtype == 'json' || $mime_type->suffix == 'json') {
    print $oauth->getLastResponse();
  } else {
    error_log(sprintf("Cowardly refusing to output a '%s' repsonse entity to a terminal.", $headers['Content-Type']));
  }
}

function parse_content_disposition_header($header) {
  preg_match_all(PRE, $header, $x, PREG_SET_ORDER);
  foreach ($x as $p)
    $content_disposition[$p['pname']] = $p['pvalue'];

  return $content_disposition;
}

function parse_content_type_header($header) {
  $mime_type = (object)[];
  preg_match(RE, $header, $m);
  foreach ($m as $i => $v)
    if (is_string($i))
      $mime_type->$i = $v;

  preg_match_all(PRE, $mime_type->parameters_scalar, $ps, PREG_SET_ORDER);
  foreach ($ps as $x => $p)
    $mime_type->parameters[$p['pname']] = $p['pvalue'];

  return $mime_type;
}

function http_parse_headers($header) {
    $retVal = array();
    $fields = explode("\r\n", preg_replace('/\x0D\x0A[\x09\x20]+/', ' ', $header));
    foreach( $fields as $field ) {
        if( preg_match('/([^:]+): (.+)/m', $field, $match) ) {
            $match[1] = preg_replace_callback('/(?<=^|[\x09\x20\x2D])./', function ($x) { return strtoupper($x[0]); }, strtolower(trim($match[1])));
            if( isset($retVal[$match[1]]) ) {
                if ( is_array( $retVal[$match[1]] ) ) {
                    $i = count($retVal[$match[1]]);
                    $retVal[$match[1]][$i] = $match[2];
                }
                else {
                    $retVal[$match[1]] = array($retVal[$match[1]], $match[2]);
                }
            } else {
                $retVal[$match[1]] = trim($match[2]);
            }
        }
    }
    return $retVal;
}
