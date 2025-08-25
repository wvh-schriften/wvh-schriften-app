import module namespace m='http://www.tei-c.org/pm/models/wvh-schriften/fo' at 'wvh-schriften-fo.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["transform/wvh-schriften.css"],
    "collection": "/db/apps/wvh-schriften/transform",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)