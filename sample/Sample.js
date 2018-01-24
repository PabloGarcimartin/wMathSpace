
if( typeof module !== 'undefined' )
require( 'wmathspace' );

var _ = wTools;

var u = _.Space.make([ 3,3 ]).copy
([
  +1, +2, +3,
  +0, +4, +5,
  +0, +0, +6,
]);

var l = _.Space.make([ 3,3 ]).copy
([
  +1, +0, +0,
  +2, +4, +0,
  +3, +5, +6,
]);

var expected = _.Space.make([ 3,3 ]).copy
([
  +14, +23, +18,
  +23, +41, +30,
  +18, +30, +36,
]);

var uxl = _.Space.mul( null,[ u,l ] );
console.log( uxl.toStr() );
