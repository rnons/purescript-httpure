module HTTPure.Query
  ( Query
  , read
  ) where

import Prelude

import Data.Array as Array
import Data.Maybe as Maybe
import Data.String as String
import Data.Tuple as Tuple
import Foreign.Object as Object
import Node.HTTP as HTTP

-- | The `Query` type is a `Object` of `Strings`, with one entry per query
-- | parameter in the request. For any query parameters that don't have values
-- | (`/some/path?query`), the value in the `Object` for that parameter will be
-- | the string `"true"`. Note that this type has an implementation of `Lookup`
-- | for `String` keys defined by `lookupObject` in [Lookup.purs](./Lookup.purs)
-- | because `lookupObject` is defined for any `Object` of `Monoids`. So you can
-- | do something like `query !! "foo"` to get the value of the query parameter
-- | "foo".
type Query = Object.Object String

-- | The `Map` of query segments in the given HTTP `Request`.
read :: HTTP.Request -> Query
read =
  HTTP.requestURL >>> split "?" >>> last >>> split "&" >>> nonempty >>> toObject
  where
    toObject = map toTuple >>> Object.fromFoldable
    nonempty = Array.filter ((/=) "")
    split = String.Pattern >>> String.split
    first = Array.head >>> Maybe.fromMaybe ""
    last = Array.tail >>> Maybe.fromMaybe [] >>> String.joinWith ""
    toTuple item = Tuple.Tuple (first itemParts) $ value $ last itemParts
      where
        value val = if val == "" then "true" else val
        itemParts = split "=" item
