import module namespace m='http://www.tei-c.org/pm/models/wvh-schriften/latex' at 'wvh-schriften-latex.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["transform/wvh-schriften.css"],
    "collection": "/db/apps/wvh-schriften/transform",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)