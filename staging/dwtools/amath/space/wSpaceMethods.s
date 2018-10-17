(function _wSpaceMethods_s_() {

'use strict';

let _ = _global_.wTools;
let vector = _.vector;
let abs = Math.abs;
let min = Math.min;
let max = Math.max;
let pow = Math.pow;
let pi = Math.PI;
let sin = Math.sin;
let cos = Math.cos;
let sqrt = Math.sqrt;
let sqr = _.sqr;
let longSlice = Array.prototype.slice;

let Parent = null;
let Self = _global_.wSpace;

_.assert( _.objectIs( vector ) );
_.assert( _.routineIs( Self ),'wSpace is not defined, please include wSpace.s first' );

// --
// make
// --

function make( dims )
{
  let proto = this ? this.Self.prototype : Self.prototype;

  _.assert( !this.instanceIs() );
  _.assert( _.longIs( dims ) || _.numberIs( dims ) );
  _.assert( arguments.length === 1,'make expects single argument array (-dims-)' );

  if( _.numberIs( dims ) )
  dims = [ dims,dims ];

  let lengthFlat = proto.atomsPerSpaceForDimensions( dims );
  let strides = proto.stridesForDimensions( dims,0 );
  let buffer = proto.array.makeArrayOfLength( lengthFlat );
  let result = new proto.Self
  ({
    buffer : buffer,
    dims : dims,
    inputTransposing : 0,
    /*strides : strides,*/
  });

  _.assert( _.arrayIdentical( strides,result._stridesEffective ) );

  return result;
}

//

function makeSquare( buffer )
{
  let proto = this ? this.Self.prototype : Self.prototype;

  let length = buffer;
  if( _.longIs( buffer ) )
  length = Math.sqrt( buffer.length );

  _.assert( !this.instanceIs() );
  _.assert( _.prototypeIs( this ) || _.constructorIs( this ) );
  _.assert( _.longIs( buffer ) || _.numberIs( buffer ) );
  _.assert( _.numberIsInt( length ),'makeSquare expects square buffer' );
  _.assert( arguments.length === 1, 'expects single argument' );

  let dims = [ length,length ];
  let atomsPerSpace = this.atomsPerSpaceForDimensions( dims );

  let inputTransposing = atomsPerSpace > 0 ? 1 : 0;
  if( _.numberIs( buffer ) )
  {
    inputTransposing = 0;
    buffer = this.array.makeArrayOfLength( atomsPerSpace );
  }
  else
  {
    buffer = proto.constructor._bufferFrom( buffer );
  }

  let result = new proto.constructor
  ({
    buffer : buffer,
    dims : dims,
    inputTransposing : inputTransposing,
  });

  return result;
}

//

function makeZero( dims )
{
  let proto = this ? this.Self.prototype : Self.prototype;

  _.assert( !this.instanceIs() );
  _.assert( _.longIs( dims ) || _.numberIs( dims ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  if( _.numberIs( dims ) )
  dims = [ dims,dims ];

  let lengthFlat = proto.atomsPerSpaceForDimensions( dims );
  let strides = proto.stridesForDimensions( dims,0 );
  let buffer = proto.array.makeArrayOfLengthZeroed( lengthFlat );
  let result = new proto.Self
  ({
    buffer : buffer,
    dims : dims,
    inputTransposing : 0,
    /*strides : strides,*/
  });

  _.assert( _.arrayIdentical( strides,result._stridesEffective ) );

  return result;
}

//

function makeIdentity( dims )
{
  let proto = this ? this.Self.prototype : Self.prototype;

  _.assert( !this.instanceIs() );
  _.assert( _.longIs( dims ) || _.numberIs( dims ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  if( _.numberIs( dims ) )
  dims = [ dims,dims ];

  let lengthFlat = proto.atomsPerSpaceForDimensions( dims );
  let strides = proto.stridesForDimensions( dims,0 );
  let buffer = proto.array.makeArrayOfLengthZeroed( lengthFlat );
  let result = new proto.Self
  ({
    buffer : buffer,
    dims : dims,
    inputTransposing : 0,
    /*strides : strides,*/
  });

  result.diagonalSet( 1 );

  _.assert( _.arrayIdentical( strides,result._stridesEffective ) );

  return result;
}

//

function makeIdentity2( src )
{
  let proto = this ? this.Self.prototype : Self.prototype;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  let result = proto.makeIdentity( 2 );

  if( src )
  result.copy( src );

  return result;
}

//

function makeIdentity3( src )
{
  let proto = this ? this.Self.prototype : Self.prototype;

_.assert( arguments.length === 0 || arguments.length === 1 );

  let result = proto.makeIdentity( 3 );

  if( src )
  result.copy( src );

  return result;
}

//

function makeIdentity4( src )
{
  let proto = this ? this.Self.prototype : Self.prototype;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  let result = proto.makeIdentity( 4 );

  if( src )
  result.copy( src );

  return result;
}

//

function makeDiagonal( diagonal )
{

  _.assert( !this.instanceIs() );
  _.assert( _.prototypeIs( this ) || _.constructorIs( this ) );
  _.assert( _.arrayIs( diagonal ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  /* */

  let length = diagonal.length;
  let dims = [ length,length ];
  let atomsPerSpace = this.atomsPerSpaceForDimensions( dims );
  let buffer = this.array.makeArrayOfLengthZeroed( atomsPerSpace );
  let result = new this.Self
  ({
    buffer : buffer,
    dims : dims,
    inputTransposing : 0,
    // strides : [ 1,length ],
  });

  result.diagonalSet( diagonal );

  return result;
}

//

function makeSimilar( m , dims )
{
  let proto = this;
  let result;

  if( proto.instanceIs() )
  {
    _.assert( arguments.length === 0 || arguments.length === 1 );
    return proto.Self.makeSimilar( proto , arguments[ 0 ] );
  }

  if( dims === undefined )
  dims = proto.dimsOf( m );

  /* */

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( _.arrayIs( dims ) && dims.length === 2 );

  /* */

  if( m instanceof Self )
  {

    let atomsPerSpace = Self.atomsPerSpaceForDimensions( dims );
    let buffer = _.longMakeSimilarZeroed( m.buffer,atomsPerSpace );
    /* could possibly be not zeroed */

    result = new m.constructor
    ({
      buffer : buffer,
      dims : dims,
      inputTransposing : 0,
    });

  }
  else if( _.longIs( m ) )
  {

    _.assert( dims[ 1 ] === 1 );
    result = _.longMakeSimilar( m, dims[ 0 ] );

  }
  else if( _.vectorIs( m ) )
  {

    _.assert( dims[ 1 ] === 1 );
    result = m.makeSimilar( dims[ 0 ] );

  }
  else _.assert( 0,'unexpected type of container',_.strTypeOf( m ) );

  return result;
}

//

function makeLine( o )
{
  let proto = this ? this.Self.prototype : Self.prototype;
  let strides = null;
  let offset = 0;
  let length = ( _.longIs( o.buffer ) || _.vectorIs( o.buffer ) ) ? o.buffer.length : o.buffer;
  let dims = null;

  _.assert( !this.instanceIs() );
  _.assert( _.spaceIs( o.buffer ) || _.vectorIs( o.buffer ) || _.arrayIs( o.buffer ) || _.bufferTypedIs( o.buffer ) || _.numberIs( o.buffer ) );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.routineOptions( makeLine,o );

  /* */

  if( _.spaceIs( o.buffer ) )
  {
    _.assert( o.buffer.dims.length === 2 );
    if( o.dimension === 0 )
    _.assert( o.buffer.dims[ 1 ] === 1 );
    else if( o.dimension === 1 )
    _.assert( o.buffer.dims[ 0 ] === 1 );

    if( !o.zeroing )
    {
      return o.buffer;
    }
    else
    {
      o.buffer = o.buffer.dims[ o.dimension ];
      length = o.buffer;
    }
  }

  /* */

  if( o.zeroing )
  {
    o.buffer = length;
  }

  if( _.vectorIs( o.buffer ) )
  {
    length = o.buffer.length;
    o.buffer = proto._bufferFrom( o.buffer );
  }

  if( _.vectorIs( o.buffer ) )
  {

    offset = o.buffer.offset;
    length = o.buffer.length;

    if( o.buffer.stride !== 1 )
    {
      if( o.dimension === 0 )
      strides = [ o.buffer.stride,o.buffer.stride ];
      else
      strides = [ o.buffer.stride,o.buffer.stride ];
    }

    o.buffer = o.buffer._vectorBuffer;

  }
  else if( _.numberIs( o.buffer ) )
  o.buffer = o.zeroing ? this.array.makeArrayOfLengthZeroed( length ) : this.array.makeArrayOfLength( length );
  else if( o.zeroing )
  o.buffer = this.array.makeArrayOfLengthZeroed( length )
  else
  o.buffer = proto.constructor._bufferFrom( o.buffer );

  /* dims */

  if( o.dimension === 0 )
  {
    dims = [ length,1 ];
  }
  else if( o.dimension === 1 )
  {
    dims = [ 1,length ];
  }
  else _.assert( 0,'bad dimension',o.dimension );

  /* */

  let result = new proto.constructor
  ({
    buffer : o.buffer,
    dims : dims,
    inputTransposing : 0,
    strides : strides,
    offset : offset,
  });

  return result;
}

makeLine.defaults =
{
  buffer : null,
  dimension : -1,
  zeroing : 1,
}

//

function makeCol( buffer )
{
  return this.makeLine
  ({
    buffer : buffer,
    zeroing : 0,
    dimension : 0,
  });
}

//

function makeColZeroed( buffer )
{
  return this.makeLine
  ({
    buffer : buffer,
    zeroing : 1,
    dimension : 0,
  });
}

//

function makeRow( buffer )
{
  return this.makeLine
  ({
    buffer : buffer,
    zeroing : 0,
    dimension : 1,
  });
}

//

function makeRowZeroed( buffer )
{
  return this.makeLine
  ({
    buffer : buffer,
    zeroing : 1,
    dimension : 1,
  });
}

// --
// converter
// --

function convertToClass( cls,src )
{
  let self = this;

  _.assert( !_.instanceIs( this ) );
  _.assert( _.constructorIs( cls ) );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  if( src.constructor === cls )
  return src;

  let result;
  if( _.spaceIs( src ) )
  {

    if( _.subclassOf( cls, src.Self ) )
    {
      _.assert( src.Self === cls,'not tested' );
      return src;
    }

    _.assert( src.dims.length === 2 );
    _.assert( src.dims[ 1 ] === 1 );

    let array;
    let atomsPerSpace = src.atomsPerSpace;

    if( _.constructorLikeArray( cls ) )
    {
      result = new cls( atomsPerSpace );
      array = result;
    }
    else if( _.constructorIsVector( cls ) )
    {
      debugger;
      array = new src.buffer.constructor( atomsPerSpace );
      result = vector.fromArray( array );
    }
    else _.assert( 0,'unknown class (-cls-)',cls.name );

    for( let i = 0 ; i < result.length ; i += 1 )
    array[ i ] = src.atomGet([ i,0 ]);

  }
  else
  {

    let atomsPerSpace = src.length;
    src = vector.from( src );

    if( _.constructorIsSpace( cls ) )
    {
      let array = new src._vectorBuffer.constructor( atomsPerSpace );
      result = new cls
      ({
        dims : [ src.length,1 ],
        buffer : array,
        inputTransposing : 0,
      });
      for( let i = 0 ; i < src.length ; i += 1 )
      result.atomSet( [ i,0 ],src.eGet( i ) );
    }
    else if( _.constructorLikeArray( cls ) )
    {
      result = new cls( atomsPerSpace );
      for( let i = 0 ; i < src.length ; i += 1 )
      result[ i ] = src.eGet( i );
    }
    else if( _.constructorIsVector( cls ) )
    {
      let array = new src._vectorBuffer.constructor( atomsPerSpace );
      result = vector.fromArray( array );
      for( let i = 0 ; i < src.length ; i += 1 )
      array[ i ] = src.eGet( i );
    }
    else _.assert( 0,'unknown class (-cls-)',cls.name );

  }

  return result;
}

//

function fromVectorImage( src )
{
  let result;

  _.assert( !this.instanceIs() );
  _.assert( arguments.length === 1, 'expects single argument' );

  if( _.vectorIs( src ) )
  {
    result = new this.Self
    ({
      buffer : src._vectorBuffer,
      dims : [ src.length,1 ],
      strides : src.stride > 1 ? [ src.stride,1 ] : undefined,
      inputTransposing : 0,
    });
  }
  else if( _.arrayIs( src ) )
  {
    result = new this.Self
    ({
      buffer : src,
      dims : [ src.length,1 ],
      inputTransposing : 0,
    });
  }
  else _.assert( 0,'cant convert',_.strTypeOf( src ),'to Space' );

  return result;
}

//

function fromScalar( scalar,dims )
{

  _.assert( !this.instanceIs() );
  _.assert( _.arrayIs( dims ) );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.numberIs( scalar );

  let result = new this.Self
  ({
    buffer : this.array.arrayFromCoercing( _.dup( scalar,this.atomsPerSpaceForDimensions( dims ) ) ),
    dims : dims,
    inputTransposing : 0,
  });

  return result;
}

//

function fromScalarForReading( scalar,dims )
{

  _.assert( !this.instanceIs() );
  _.assert( _.arrayIs( dims ) );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.numberIs( scalar );

  let buffer = this.array.makeArrayOfLength( 1 );
  buffer[ 0 ] = scalar;

  let result = new this.Self
  ({
    buffer : buffer,
    dims : dims,
    strides : _.dup( 0,dims.length ),
  });

  return result;
}

//

function from( src,dims )
{
  let result;

  _.assert( !this.instanceIs() );
  _.assert( _.arrayIs( dims ) || dims == undefined );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( src === null )
  {
    _.assert( _.arrayIs( dims ) );
    result = this.makeZero( dims );
  }
  else if( src instanceof Self )
  {
    result = src;
  }
  else if( _.numberIs( src ) )
  {
    _.assert( _.arrayIs( dims ) );
    result = this.fromScalar( src,dims );
  }
  else
  {
    result = this.fromVectorImage( src );
  }

  _.assert( !dims || result.hasShape( dims ) );

  return result;
}

//

function fromForReading( src,dims )
{
  let result;

  _.assert( !this.instanceIs() );
  _.assert( _.arrayIs( dims ) || dims == undefined );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( src instanceof Self )
  {
    result = src;
  }
  else if( _.numberIs( src ) )
  {
    _.assert( _.arrayIs( dims ) );
    result = this.fromScalarForReading( src,dims );
  }
  else
  {
    let result = this.fromVectorImage( src );
  }

  _.assert( !dims || result.hasShape( dims ) );

  return result;
}

//

function fromTransformations( position, quaternion, scale )
{
  let self = this;

  _.assert( arguments.length === 3, 'expects exactly three argument' );

  self.fromQuat( quaternion );
  self.scaleApply( scale );
  self.positionSet( position );

  return self;
}

//

function fromQuat( q )
{
  let self = this;

  q = _.vector.from( q );
  let x = q.eGet( 0 );
  let y = q.eGet( 1 );
  let z = q.eGet( 2 );
  let w = q.eGet( 3 );

  _.assert( self.atomsPerElement >= 3 );
  _.assert( self.length >= 3 );
  _.assert( q.length === 4 );
  _.assert( arguments.length === 1, 'expects single argument' );

  let x2 = x + x, y2 = y + y, z2 = z + z;
  let xx = x * x2, xy = x * y2, xz = x * z2;
  let yy = y * y2, yz = y * z2, zz = z * z2;
  let wx = w * x2, wy = w * y2, wz = w * z2;

  self.atomSet( [ 0,0 ] , 1 - ( yy + zz ) );
  self.atomSet( [ 0,1 ] , xy - wz );
  self.atomSet( [ 0,2 ] , xz + wy );

  self.atomSet( [ 1,0 ] , xy + wz );
  self.atomSet( [ 1,1 ] , 1 - ( xx + zz ) );
  self.atomSet( [ 1,2 ] , yz - wx );

  self.atomSet( [ 2,0 ] , xz - wy );
  self.atomSet( [ 2,1 ] , yz + wx );
  self.atomSet( [ 2,2 ] , 1 - ( xx + yy ) );

  if( self.dims[ 0 ] > 3 )
  {
    self.atomSet( [ 3,0 ] , 0 );
    self.atomSet( [ 3,1 ] , 0 );
    self.atomSet( [ 3,2 ] , 0 );
    self.atomSet( [ 0,3 ], 0 );
    self.atomSet( [ 1,3 ], 0 );
    self.atomSet( [ 2,3 ], 0 );
    self.atomSet( [ 3,3 ], 1 );
  }

  return self;
}

//

function fromQuatWithScale( q )
{
  let self = this;

  q = _.vector.from( q );
  let m = q.mag();
  let x = q.eGet( 0 ) / m;
  let y = q.eGet( 1 ) / m;
  let z = q.eGet( 2 ) / m;
  let w = q.eGet( 3 ) / m;

  _.assert( self.atomsPerElement >= 3 );
  _.assert( self.length >= 3 );
  _.assert( q.length === 4 );
  _.assert( arguments.length === 1, 'expects single argument' );

  let x2 = x + x, y2 = y + y, z2 = z + z;
  let xx = x * x2, xy = x * y2, xz = x * z2;
  let yy = y * y2, yz = y * z2, zz = z * z2;
  let wx = w * x2, wy = w * y2, wz = w * z2;

  self.atomSet( [ 0,0 ] , m*( 1 - ( yy + zz ) ) );
  self.atomSet( [ 0,1 ] , m*( xy - wz ) );
  self.atomSet( [ 0,2 ] , m*( xz + wy ) );

  self.atomSet( [ 1,0 ] , m*( xy + wz ) );
  self.atomSet( [ 1,1 ] , m*( 1 - ( xx + zz ) ) );
  self.atomSet( [ 1,2 ] , m*( yz - wx ) );

  self.atomSet( [ 2,0 ] , m*( xz - wy ) );
  self.atomSet( [ 2,1 ] , m*( yz + wx ) );
  self.atomSet( [ 2,2 ] , m*( 1 - ( xx + yy ) ) );

  if( self.dims[ 0 ] > 3 )
  {
    self.atomSet( [ 3,0 ] , 0 );
    self.atomSet( [ 3,1 ] , 0 );
    self.atomSet( [ 3,2 ] , 0 );
    self.atomSet( [ 0,3 ], 0 );
    self.atomSet( [ 1,3 ], 0 );
    self.atomSet( [ 2,3 ], 0 );
    self.atomSet( [ 3,3 ], 1 );
  }

  return self;
}

//

function fromAxisAndAngle( axis,angle )
{
  let self = this;
  axis = _.vector.from( axis );

  // let m = axis.mag();
  // debugger;

  let x = axis.eGet( 0 );
  let y = axis.eGet( 1 );
  let z = axis.eGet( 2 );

  _.assert( axis.length === 3 );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  let s = Math.sin( angle );
  let c = Math.cos( angle );
  let t = 1 - c;

  let m00 = c + x*x*t;
  let m11 = c + y*y*t;
  let m22 = c + z*z*t;

  let a = x*y*t;
  let b = z*s;

  let m10 = a + b;
  let m01 = a - b;

  a = x*z*t;
  b = y*s;

  let m20 = a - b;
  let m02 = a + b;

  a = y*z*t;
  b = x*s;

  let m21 = a + b;
  let m12 = a - b;

  self.atomSet( [ 0,0 ],m00 );
  self.atomSet( [ 1,0 ],m10 );
  self.atomSet( [ 2,0 ],m20 );

  self.atomSet( [ 0,1 ],m01 );
  self.atomSet( [ 1,1 ],m11 );
  self.atomSet( [ 2,1 ],m21 );

  self.atomSet( [ 0,2 ],m02 );
  self.atomSet( [ 1,2 ],m12 );
  self.atomSet( [ 2,2 ],m22 );

  return self;
}

//

function fromEuler( euler )
{
  let self = this;
  // let euler = _.vector.from( euler );

  // _.assert( self.dims[ 0 ] >= 3 );
  // _.assert( self.dims[ 1 ] >= 3 );
  _.assert( arguments.length === 1, 'expects single argument' );

  _.euler.toMatrix( euler,self );

  return self;
}

//

function fromAxisAndAngleWithScale( axis,angle )
{
  let self = this;
  axis = _.vector.from( axis );

  let m = axis.mag();
  debugger;
  let x = axis.eGet( 0 ) / m;
  let y = axis.eGet( 1 ) / m;
  let z = axis.eGet( 2 ) / m;

  _.assert( axis.length === 3 );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  let s = Math.sin( angle );
  let c = Math.cos( angle );
  let t = 1 - c;

  let m00 = c + x*x*t;
  let m11 = c + y*y*t;
  let m22 = c + z*z*t;

  let a = x*y*t;
  let b = z*s;

  let m10 = a + b;
  let m01 = a - b;

  a = x*z*t;
  b = y*s;

  let m20 = a - b;
  let m02 = a + b;

  a = y*z*t;
  b = x*s;

  let m21 = a + b;
  let m12 = a - b;

  self.atomSet( [ 0,0 ],m*m00 );
  self.atomSet( [ 1,0 ],m*m10 );
  self.atomSet( [ 2,0 ],m*m20 );

  self.atomSet( [ 0,1 ],m*m01 );
  self.atomSet( [ 1,1 ],m*m11 );
  self.atomSet( [ 2,1 ],m*m21 );

  self.atomSet( [ 0,2 ],m*m02 );
  self.atomSet( [ 1,2 ],m*m12 );
  self.atomSet( [ 2,2 ],m*m22 );

  return self;
}

// --
// borrow
// --

function _tempBorrow( src,dims,index )
{
  let cls;

  _.assert( arguments.length === 3, 'expects exactly three argument' );
  _.assert( src instanceof Self || src === null );
  _.assert( _.arrayIs( dims ) || dims instanceof Self || dims === null );

  if( !src )
  {

    cls = this.array.ArrayType;
    if( !dims )
    dims = src;

  }
  else
  {

    if( src.buffer )
    cls = src.buffer.constructor;

    if( !dims )
    if( src.dims )
    dims = src.dims.slice();

  }

  if( dims instanceof Self )
  dims = dims.dims;

  _.assert( _.routineIs( cls ) );
  _.assert( _.arrayIs( dims ) );
  _.assert( index < 3 );

  let key = cls.name + '_' + dims.join( 'x' );

  if( this._tempMatrices[ index ][ key ] )
  return this._tempMatrices[ index ][ key ];

  let result = this._tempMatrices[ index ][ key ] = new Self
  ({
    dims : dims,
    buffer : new cls( this.atomsPerSpaceForDimensions( dims ) ),
    inputTransposing : 0,
  });

  return result;
}

//

function tempBorrow1( src )
{

  _.assert( arguments.length <= 1 );
  if( src === undefined )
  src = this;

  if( this instanceof Self )
  return Self._tempBorrow( this, src , 0 );
  else if( src instanceof Self )
  return Self._tempBorrow( src, src , 0 );
  else
  return Self._tempBorrow( null, src , 0 );

}

//

function tempBorrow2( src )
{

  _.assert( arguments.length <= 1 );
  if( src === undefined )
  src = this;

  if( this instanceof Self )
  return Self._tempBorrow( this, src , 1 );
  else if( src instanceof Self )
  return Self._tempBorrow( src, src , 1 );
  else
  return Self._tempBorrow( null, src , 1 );

}

//

function tempBorrow3( src )
{

  _.assert( arguments.length <= 1 );
  if( src === undefined )
  src = this;

  if( this instanceof Self )
  return Self._tempBorrow( this, src , 2 );
  else if( src instanceof Self )
  return Self._tempBorrow( src, src , 2 );
  else
  return Self._tempBorrow( null, src , 2 );

}

// --
// mul
// --

function spacePow( exponent )
{

  _.assert( _.instanceIs( this ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  let t = this.tempBorrow( this );

  // self.mul(  );

}

//

function mul_static( dst,srcs )
{

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( _.arrayIs( srcs ) );
  _.assert( srcs.length >= 2 );

  /* adjust dst */

  if( dst === null )
  {
    let dims = [ this.nrowOf( srcs[ srcs.length-2 ] ) , this.ncolOf( srcs[ srcs.length-1 ] ) ];
    dst = this.makeSimilar( srcs[ srcs.length-1 ] , dims );
  }

  /* adjust srcs */

  srcs = srcs.slice();
  let dstClone = null;

  let odst = dst;
  dst = this.from( dst );

  for( let s = 0 ; s < srcs.length ; s++ )
  {

    srcs[ s ] = this.from( srcs[ s ] );

    if( dst === srcs[ s ] || dst.buffer === srcs[ s ].buffer )
    {
      if( dstClone === null )
      {
        dstClone = dst.tempBorrow1();
        dstClone.copy( dst );
      }
      srcs[ s ] = dstClone;
    }

    _.assert( dst.buffer !== srcs[ s ].buffer );

  }

  /* */

  dst = this.mul2Matrices( dst , srcs[ 0 ] , srcs[ 1 ] );

  /* */

  if( srcs.length > 2 )
  {

    let dst2 = null;
    let dst3 = dst;
    for( let s = 2 ; s < srcs.length ; s++ )
    {
      let src = srcs[ s ];
      if( s % 2 === 0 )
      {
        dst2 = dst.tempBorrow2([ dst3.dims[ 0 ],src.dims[ 1 ] ]);
        this.mul2Matrices( dst2 , dst3 , src );
      }
      else
      {
        dst3 = dst.tempBorrow3([ dst2.dims[ 0 ],src.dims[ 1 ] ]);
        this.mul2Matrices( dst3 , dst2 , src );
      }
    }

    if( srcs.length % 2 === 0 )
    this.copyTo( odst,dst3 );
    else
    this.copyTo( odst,dst2 );

  }
  else
  {
    this.copyTo( odst,dst );
  }

  return odst;
}

//

function mul( srcs )
{
  let dst = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.arrayIs( srcs ) );

  return dst.Self.mul( dst,srcs );
}

//

function mul2Matrices_static( dst,src1,src2 )
{

  src1 = Self.fromForReading( src1 );
  src2 = Self.fromForReading( src2 );

  if( dst === null )
  {
    dst = this.make([ src1.dims[ 0 ],src2.dims[ 1 ] ]);
  }

  _.assert( arguments.length === 3, 'expects exactly three argument' );
  _.assert( src1.dims.length === 2 );
  _.assert( src2.dims.length === 2 );
  _.assert( dst instanceof Self );
  _.assert( src1 instanceof Self );
  _.assert( src2 instanceof Self );
  _.assert( dst !== src1 );
  _.assert( dst !== src2 );
  _.assert( src1.dims[ 1 ] === src2.dims[ 0 ],'expects src1.dims[ 1 ] === src2.dims[ 0 ]' );
  _.assert( src1.dims[ 0 ] === dst.dims[ 0 ] );
  _.assert( src2.dims[ 1 ] === dst.dims[ 1 ] );

  let nrow = dst.nrow;
  let ncol = dst.ncol;

  for( let r = 0 ; r < nrow ; r++ )
  for( let c = 0 ; c < ncol ; c++ )
  {
    let row = src1.rowVectorGet( r );
    let col = src2.colVectorGet( c );
    let dot = vector.dot( row,col );
    dst.atomSet( [ r,c ],dot );
  }

  return dst;
}

//

function mul2Matrices( src1,src2 )
{
  let dst = this;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  return dst.Self.mul2Matrices( dst,src1,src2 );
}

//

function mulLeft( src )
{
  let dst = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  // debugger;

  dst.mul([ dst,src ])

  return dst;
}

//

function mulRight( src )
{
  let dst = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  // debugger;

  dst.mul([ src,dst ]);
  // dst.mul2Matrices( src,dst );

  return dst;
}

// //
//
// function _mulMatrix( src )
// {
//
//   _.assert( arguments.length === 1, 'expects single argument' );
//   _.assert( src.breadth.length === 1 );
//
//   let self = this;
//   let atomsPerRow = self.atomsPerRow;
//   let atomsPerCol = src.atomsPerCol;
//   let code = src.buffer.constructor.name + '_' + atomsPerRow + 'x' + atomsPerCol;
//
//   debugger;
//   if( !self._tempMatrices[ code ] )
//   self._tempMatrices[ code ] = self.Self.make([ atomsPerCol,atomsPerRow ]);
//   let dst = self._tempMatrices[ code ]
//
//   debugger;
//   dst.mul2Matrices( dst,self,src );
//   debugger;
//
//   self.copy( dst );
//
//   return self;
// }
//
// //
//
// function mulAssigning( src )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'expects single argument' );
//   _.assert( self.breadth.length === 1 );
//
//   let result = self._mulMatrix( src );
//
//   return result;
// }
//
// //
//
// function mulCopying( src )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'expects single argument' );
//   _.assert( src.dims.length === 2 );
//   _.assert( self.dims.length === 2 );
//
//   let result = Self.make( src.dims );
//   result.mul2Matrices( result,self,src );
//
//   return result;
// }

// --
// partial accessors
// --

function zero()
{
  let self = this;

  _.assert( arguments.length === 0 );

  self.atomEach( ( it ) => self.atomSet( it.indexNd,0 ) );

  return self;
}

//

function identify()
{
  let self = this;

  _.assert( arguments.length === 0 );

  self.atomEach( ( it ) => it.indexNd[ 0 ] === it.indexNd[ 1 ] ? self.atomSet( it.indexNd,1 ) : self.atomSet( it.indexNd,0 ) );

  return self;
}

//

function diagonalSet( src )
{
  let self = this;
  let length = Math.min( self.atomsPerCol,self.atomsPerRow );

  if( src instanceof Self )
  src = src.diagonalVectorGet();

  src = vector.fromMaybeNumber( src,length );

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( self.dims.length === 2 );
  _.assert( src.length === length );

  for( let i = 0 ; i < length ; i += 1 )
  {
    self.atomSet( [ i,i ],src.eGet( i ) );
  }

  return self;
}

//

function diagonalVectorGet()
{
  let self = this;
  let length = Math.min( self.atomsPerCol,self.atomsPerRow );
  let strides = self._stridesEffective;

  _.assert( arguments.length === 0 );
  _.assert( self.dims.length === 2 );

  let result = vector.fromSubArrayWithStride( self.buffer, self.offset, length, strides[ 0 ] + strides[ 1 ] );

  return result;
}

//

function triangleLowerSet( src )
{
  let self = this;
  let nrow = self.nrow;
  let ncol = self.ncol;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( self.dims.length === 2 );

  _.assert( _.numberIs( src ) || src instanceof Self );

  if( src instanceof Self )
  {

    _.assert( src.dims[ 0 ] >= self.dims[ 0 ] );
    _.assert( src.dims[ 1 ] >= min( self.dims[ 0 ]-1,self.dims[ 1 ] ) );

    for( let r = 1 ; r < nrow ; r++ )
    {
      let cl = min( r,ncol );
      for( let c = 0 ; c < cl ; c++ )
      self.atomSet( [ r,c ],src.atomGet([ r,c ]) );
    }

  }
  else
  {

    for( let r = 1 ; r < nrow ; r++ )
    {
      let cl = min( r,ncol );
      for( let c = 0 ; c < cl ; c++ )
      self.atomSet( [ r,c ],src );
    }

  }

  return self;
}

//

function triangleUpperSet( src )
{
  let self = this;
  let nrow = self.nrow;
  let ncol = self.ncol;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( self.dims.length === 2 );

  _.assert( _.numberIs( src ) || src instanceof Self );

  if( src instanceof Self )
  {

    _.assert( src.dims[ 1 ] >= self.dims[ 1 ] );
    _.assert( src.dims[ 0 ] >= min( self.dims[ 1 ]-1,self.dims[ 0 ] ) );

    for( let c = 1 ; c < ncol ; c++ )
    {
      let cl = min( c,nrow );
      for( let r = 0 ; r < cl ; r++ )
      self.atomSet( [ r,c ],src.atomGet([ r,c ]) );
    }

  }
  else
  {

    for( let c = 1 ; c < ncol ; c++ )
    {
      let cl = min( c,nrow );
      for( let r = 0 ; r < cl ; r++ )
      self.atomSet( [ r,c ],src );
    }

  }

  return self;
}

// --
// transformer
// --

// function applyMatrixToVector( dstVector )
// {
//   let self = this;
//
//   _.assert( 0,'deprecated' );
//
//   vector.matrixApplyTo( dstVector,self );
//
//   return self;
// }

//

// function matrixHomogenousApply( dstVector )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1 )
//   _.assert( 0,'not tested' );
//
//   vector.matrixHomogenousApply( dstVector,self );
//
//   return self;
// }

function matrixApplyTo( dstVector )
{
  let self = this;

  if( self.hasShape([ 3,3 ]) )
  {

    let dstVectorv = _.vector.from( dstVector );
    let x = dstVectorv.eGet( 0 );
    let y = dstVectorv.eGet( 1 );
    let z = dstVectorv.eGet( 2 );

    let s00 = self.atomGet([ 0,0 ]), s10 = self.atomGet([ 1,0 ]), s20 = self.atomGet([ 2,0 ]);
    let s01 = self.atomGet([ 0,1 ]), s11 = self.atomGet([ 1,1 ]), s21 = self.atomGet([ 2,1 ]);
    let s02 = self.atomGet([ 0,2 ]), s12 = self.atomGet([ 1,2 ]), s22 = self.atomGet([ 2,2 ]);

    dstVectorv.eSet( 0 , s00 * x + s01 * y + s02 * z );
    dstVectorv.eSet( 1 , s10 * x + s11 * y + s12 * z );
    dstVectorv.eSet( 2 , s20 * x + s21 * y + s22 * z );

    return dstVector;
  }
  else if( self.hasShape([ 2,2 ]) )
  {

    let dstVectorv = _.vector.from( dstVector );
    let x = dstVectorv.eGet( 0 );
    let y = dstVectorv.eGet( 1 );

    let s00 = self.atomGet([ 0,0 ]), s10 = self.atomGet([ 1,0 ]);
    let s01 = self.atomGet([ 0,1 ]), s11 = self.atomGet([ 1,1 ]);

    dstVectorv.eSet( 0 , s00 * x + s01 * y );
    dstVectorv.eSet( 1 , s10 * x + s11 * y );

    return dstVector;
  }

  return Self.mul( dstVector,[ self,dstVector ] );
}

//

function matrixHomogenousApply( dstVector )
{
  let self = this;
  let _dstVector = vector.from( dstVector );
  let dstLength = dstVector.length;
  let ncol = self.ncol;
  let nrow = self.nrow;
  let result = new Array( nrow );

  _.assert( arguments.length === 1 )
  _.assert( dstLength === ncol-1 );

  result[ dstLength ] = 0;
  for( let i = 0 ; i < nrow ; i += 1 )
  {
    let row = self.rowVectorGet( i );

    result[ i ] = 0;
    for( let j = 0 ; j < dstLength ; j++ )
    result[ i ] += row.eGet( j ) * _dstVector.eGet( j );
    result[ i ] += row.eGet( dstLength );

  }

  for( let j = 0 ; j < dstLength ; j++ )
  _dstVector.eSet( j,result[ j ] / result[ dstLength ] );

  return dstVector;
}

//

function matrixDirectionsApply( dstVector )
{
  let self = this;
  let dstLength = dstVector.length;
  let ncol = self.ncol;
  let nrow = self.nrow;

  _.assert( arguments.length === 1 )
  _.assert( dstLength === ncol-1 );

  debugger;

  Self.mul( v,[ self.subspace([ [ 0,v.length ],[ 0,v.length ] ]),v ] );
  vector.normalize( v );

  return dstVector;
}
//

function positionGet()
{
  let self = this;
  let l = self.length;
  let loe = self.atomsPerElement;
  let result = self.colVectorGet( l-1 );

  _.assert( arguments.length === 0 );

  // debugger;
  result = vector.fromSubArray( result,0,loe-1 );

  //let result = self.elementsInRangeGet([ (l-1)*loe,l*loe ]);
  //let result = vector.fromSubArray( this.buffer,12,3 );

  return result;
}

//

function positionSet( src )
{
  let self = this;
  src = vector.fromArray( src );
  let dst = this.positionGet();

  _.assert( src.length === dst.length );

  vector.assign( dst, src );
  return dst;
}

//

function scaleMaxGet( dst )
{
  let self = this;
  let scale = self.scaleGet( dst );
  let result = _.avector.reduceToMaxAbs( scale ).value;
  return result;
}

//

function scaleMeanGet( dst )
{
  let self = this;
  let scale = self.scaleGet( dst );
  let result = _.avector.reduceToMean( scale );
  return result;
}

//

function scaleMagGet( dst )
{
  let self = this;
  let scale = self.scaleGet( dst );
  let result = _.avector.mag( scale );
  return result;
}

//

function scaleGet( dst )
{
  let self = this;
  let l = self.length-1;
  let loe = self.atomsPerElement;

  if( dst )
  {
    if( _.arrayIs( dst ) )
    dst.length = self.length-1;
  }

  if( dst )
  l = dst.length;
  else
  dst = _.vector.from( self.array.makeArrayOfLengthZeroed( self.length-1 ) );

  let dstv = _.vector.from( dst );

  _.assert( arguments.length === 0 || arguments.length === 1 );

  for( let i = 0 ; i < l ; i += 1 )
  dstv.eSet( i , vector.mag( vector.fromSubArray( this.buffer,loe*i,loe-1 ) ) );

  return dst;
}

//

function scaleSet( src )
{
  let self = this;
  src = vector.fromArray( src );
  let l = self.length;
  let loe = self.atomsPerElement;
  let cur = this.scaleGet();

  _.assert( src.length === l-1 );

  for( let i = 0 ; i < l-1 ; i += 1 )
  vector.mulScalar( self.eGet( i ),src.eGet( i ) / cur[ i ] );

  let lastElement = self.eGet( l-1 );
  vector.mulScalar( lastElement,1 / lastElement.eGet( loe-1 ) );

}

//

function scaleAroundSet( scale,center )
{
  let self = this;
  scale = vector.fromArray( scale );
  let l = self.length;
  let loe = self.atomsPerElement;
  let cur = this.scaleGet();

  _.assert( scale.length === l-1 );

  for( let i = 0 ; i < l-1 ; i += 1 )
  vector.mulScalar( self.eGet( i ),scale.eGet( i ) / cur[ i ] );

  let lastElement = self.eGet( l-1 );
  vector.mulScalar( lastElement,1 / lastElement.eGet( loe-1 ) );

  /* */

  debugger;
  let center = vector.fromArray( center );
  let pos = vector.slice( scale );
  pos = vector.fromArray( pos );
  vector.mulScalar( pos,-1 );
  vector.addScalar( pos, 1 );
  vector.mulVectors( pos, center );

  self.positionSet( pos );

}

//

function scaleApply( src )
{
  let self = this;
  src = vector.fromArray( src );
  let ape = self.atomsPerElement;
  let l = self.length;

  for( let i = 0 ; i < ape ; i += 1 )
  {
    let c = self.rowVectorGet( i );
    c = vector.fromSubArray( c,0,l-1 );
    vector.mulVectors( c,src );
  }

}

// --
// triangulator
// --

function _triangulateGausian( o )
{
  let self = this;
  let nrow = self.nrow;
  let ncol = Math.min( self.ncol,nrow );

  _.routineOptions( _triangulateGausian,o );

  if( o.onPivot && !o.pivots )
  {
    o.pivots = [];
    for( let i = 0 ; i < self.dims.length ; i += 1 )
    o.pivots[ i ] = _.arrayFromRange([ 0, self.dims[ i ] ]);
  }

  if( o.y !== null )
  o.y = Self.from( o.y );

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( !o.y || o.y.dims[ 0 ] === self.dims[ 0 ] );

  /* */

  if( o.y )
  for( let r1 = 0 ; r1 < ncol ; r1++ )
  {

    if( o.onPivot )
    o.onPivot.call( self,r1,o );

    let row1 = self.rowVectorGet( r1 );
    let yrow1 = o.y.rowVectorGet( r1 );
    let scaler1 = row1.eGet( r1 );
    if( o.normal )
    {
      vector.divScalar( row1,scaler1 );
      vector.divScalar( yrow1,scaler1 );
      scaler1 = 1;
    }

    for( let r2 = r1+1 ; r2 < nrow ; r2++ )
    {
      let row2 = self.rowVectorGet( r2 );
      let yrow2 = o.y.rowVectorGet( r2 );
      let scaler = row2.eGet( r1 ) / scaler1;
      vector.subScaled( row2,row1,scaler );
      vector.subScaled( yrow2,yrow1,scaler );
    }

    // logger.log( 'self',self );

  }
  else for( let r1 = 0 ; r1 < ncol ; r1++ )
  {

    if( o.onPivot )
    o.onPivot.call( self,r1,o );

    let row1 = self.rowVectorGet( r1 );
    let scaler1 = row1.eGet( r1 );
    if( o.normal )
    {
      vector.divScalar( row1,scaler1 );
      scaler1 = 1;
    }

    for( let r2 = r1+1 ; r2 < nrow ; r2++ )
    {
      let row2 = self.rowVectorGet( r2 );
      let scaler = row2.eGet( r1 ) / scaler1;
      vector.subScaled( row2,row1,scaler );
    }

    // logger.log( 'self',self );

  }

  return o.pivots;
}

_triangulateGausian.defaults =
{
  y : null,
  onPivot : null,
  pivots : null,
  normal : 0,
}

//

function triangulateGausian( y )
{
  let self = this;
  let o = Object.create( null );
  o.y = y;
  return self._triangulateGausian( o );

  // let self = this;
  // let nrow = self.nrow;
  // let ncol = Math.min( self.ncol,nrow );
  //
  // if( y !== undefined )
  // y = Self.from( y );
  //
  // _.assert( arguments.length === 0 || arguments.length === 1 );
  // _.assert( !y || y.dims[ 0 ] === self.dims[ 0 ] );
  //
  // if( y )
  // for( let r1 = 0 ; r1 < ncol ; r1++ )
  // {
  //   let row1 = self.rowVectorGet( r1 );
  //   let yrow1 = y.rowVectorGet( r1 );
  //   let scaler1 = row1.eGet( r1 );
  //
  //   for( let r2 = r1+1 ; r2 < nrow ; r2++ )
  //   {
  //     let row2 = self.rowVectorGet( r2 );
  //     let yrow2 = y.rowVectorGet( r2 );
  //     let scaler = row2.eGet( r1 ) / scaler1;
  //     vector.subScaled( row2,row1,scaler );
  //     vector.subScaled( yrow2,yrow1,scaler );
  //   }
  //
  // }
  // else for( let r1 = 0 ; r1 < ncol ; r1++ )
  // {
  //   let row1 = self.rowVectorGet( r1 );
  //
  //   for( let r2 = r1+1 ; r2 < nrow ; r2++ )
  //   {
  //     let row2 = self.rowVectorGet( r2 );
  //     let scaler = row2.eGet( r1 ) / row1.eGet( r1 );
  //     vector.subScaled( row2,row1,scaler );
  //   }
  //
  // }
  //
  // return self;
}

//

function triangulateGausianNormal( y )
{
  let self = this;
  let o = Object.create( null );
  o.y = y;
  o.normal = 1;
  return self._triangulateGausian( o );

  //

  self = this;
  let nrow = self.nrow;
  let ncol = Math.min( self.ncol,nrow );

  if( y !== undefined )
  y = Self.from( y );

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( !y || y.dims[ 0 ] === self.dims[ 0 ] );

  if( y )
  for( let r1 = 0 ; r1 < ncol ; r1++ )
  {
    let row1 = self.rowVectorGet( r1 );
    let yrow1 = y.rowVectorGet( r1 );
    let scaler1 = row1.eGet( r1 );
    vector.divScalar( row1,scaler1 );
    vector.divScalar( yrow1,scaler1 );

    for( let r2 = r1+1 ; r2 < nrow ; r2++ )
    {
      let row2 = self.rowVectorGet( r2 );
      let yrow2 = y.rowVectorGet( r2 );
      let scaler = row2.eGet( r1 );
      vector.subScaled( row2,row1,scaler );
      vector.subScaled( yrow2,yrow1,scaler );
    }

  }
  else for( let r1 = 0 ; r1 < ncol ; r1++ )
  {
    let row1 = self.rowVectorGet( r1 );
    let scaler1 = row1.eGet( r1 );
    vector.divScalar( row1,scaler1 );

    for( let r2 = r1+1 ; r2 < nrow ; r2++ )
    {
      let row2 = self.rowVectorGet( r2 );
      let scaler = row2.eGet( r1 );
      vector.subScaled( row2,row1,scaler );
    }

  }

  return self;
}

//

function triangulateGausianPivoting( y )
{
  let self = this;
  let o = Object.create( null );
  o.y = y;
  o.onPivot = self._pivotRook;
  return self._triangulateGausian( o );
}

//

function triangulateLu()
{
  let self = this;
  let nrow = self.nrow;
  let ncol = Math.min( self.ncol,nrow );

  _.assert( arguments.length === 0 );

  logger.log( 'self',self );

  for( let r1 = 0 ; r1 < ncol ; r1++ )
  {
    let row1 = self.rowVectorGet( r1 );
    let scaler1 = row1.eGet( r1 );
    row1 = row1.subarray( r1+1 );

    for( let r2 = r1+1 ; r2 < nrow ; r2++ )
    {
      let row2 = self.rowVectorGet( r2 );
      let scaler = row2.eGet( r1 ) / scaler1;
      vector.subScaled( row2.subarray( r1+1 ),row1,scaler );
      row2.eSet( r1, scaler );
    }

    logger.log( 'self',self );
  }

  return self;
}

//

function triangulateLuNormal()
{
  let self = this;
  let nrow = self.nrow;
  let ncol = Math.min( self.ncol,nrow );

  _.assert( arguments.length === 0 );

  for( let r1 = 0 ; r1 < ncol ; r1++ )
  {
    let row1 = self.rowVectorGet( r1 );
    let scaler1 = row1.eGet( r1 );
    row1 = row1.subarray( r1+1 );
    vector.divScalar( row1,scaler1 );

    for( let r2 = r1+1 ; r2 < nrow ; r2++ )
    {
      let row2 = self.rowVectorGet( r2 );
      let scaler = row2.eGet( r1 );
      vector.subScaled( row2.subarray( r1+1 ),row1,scaler );
      row2.eSet( r1, scaler );
    }

  }

  return self;
}

//

function triangulateLuPivoting( pivots )
{
  let self = this;
  let nrow = self.nrow;
  let ncol = Math.min( self.ncol,nrow );

  if( !pivots )
  {
    pivots = [];
    for( let i = 0 ; i < self.dims.length ; i += 1 )
    pivots[ i ] = _.arrayFromRange([ 0, self.dims[ i ] ]);
  }

  let o = Object.create( null );
  o.pivots = pivots;

  /* */

  _.assert( self.dims.length === 2 );
  _.assert( _.arrayIs( pivots ) );
  _.assert( pivots.length === 2 );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  /* */

  logger.log( 'self',self );

  for( let r1 = 0 ; r1 < ncol ; r1++ )
  {

    self._pivotRook.call( self, r1, o );

    let row1 = self.rowVectorGet( r1 );
    let scaler1 = row1.eGet( r1 );
    row1 = row1.subarray( r1+1 );

    for( let r2 = r1+1 ; r2 < nrow ; r2++ )
    {
      let row2 = self.rowVectorGet( r2 );
      let scaler = row2.eGet( r1 ) / scaler1;
      vector.subScaled( row2.subarray( r1+1 ),row1,scaler );
      row2.eSet( r1, scaler );
    }

    logger.log( 'self',self );

  }

  return pivots;
}

//

function _pivotRook( i,o )
{
  let self = this;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( o.pivots )

  let row1 = self.rowVectorGet( i ).subarray( i );
  let col1 = self.colVectorGet( i ).subarray( i );
  let value = row1.eGet( 0 );

  let maxr = vector.reduceToMaxAbs( row1 );
  let maxc = vector.reduceToMaxAbs( col1 );

  if( maxr.value > maxc.value )
  {
    if( maxr.value === value )
    return false;
    let i2 = maxr.index + i;
    _.arraySwap( o.pivots[ 1 ],i,i2 );
    self.colsSwap( i,i2 );
  }
  else
  {
    if( maxc.value === value )
    return false;
    let i2 = maxc.index + i;
    _.arraySwap( o.pivots[ 0 ],i,i2 );
    self.rowsSwap( i,i2 );
    if( o.y )
    o.y.rowsSwap( i,i2 );
  }

  return true;
}

// --
// solver
// --

function solve( x,m,y )
{
  _.assert( arguments.length === 3, 'expects exactly three argument' );
  return this.solveWithTrianglesPivoting( x,m,y )
}

//

function _solveOptions( args )
{
  let o = Object.create( null );
  o.x = args[ 0 ];
  o.m = args[ 1 ];
  o.y = args[ 2 ];

  o.oy = o.y;
  o.ox = o.x;

  if( o.x === null )
  {
    if( _.longIs( o.y ) )
    o.x = o.y.slice();
    else
    o.x = o.y.clone();
    o.ox = o.x;
  }
  else
  {
    if( !_.spaceIs( o.x ) )
    o.x = vector.from( o.x );
    this.copyTo( o.x,o.y );
  }

  if( !_.spaceIs( o.y ) )
  o.y = vector.from( o.y );

  if( !_.spaceIs( o.x ) )
  o.x = vector.from( o.x );

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( this.shapesAreSame( o.x , o.y ) );
  _.assert( o.m.dims[ 0 ] === this.nrowOf( o.x ) );

  return o;
}

//

function solveWithGausian()
{
  let o = this._solveOptions( arguments );

  o.m.triangulateGausian( o.x );
  this.solveTriangleUpper( o.x,o.m,o.x );

  // o.x = this.convertToClass( o.oy.constructor,o.x );
  return o.ox;
}

//

function solveWithGausianPivoting()
{
  let o = this._solveOptions( arguments );

  let pivots = o.m.triangulateGausianPivoting( o.x );
  this.solveTriangleUpper( o.x,o.m,o.x );
  Self.vectorPivotBackward( o.x,pivots[ 1 ] );

  return o.ox;
}

//

function _solveWithGaussJordan( o )
{

  let nrow = o.m.nrow;
  let ncol = Math.min( o.m.ncol,nrow );

  o.x = this.from( o.x );
  o.y = o.x;

  /* */

  if( o.onPivot && !o.pivots )
  {
    o.pivots = [];
    for( let i = 0 ; i < o.m.dims.length ; i += 1 )
    o.pivots[ i ] = _.arrayFromRange([ 0, o.m.dims[ i ] ]);
  }

  /* */

  for( let r1 = 0 ; r1 < ncol ; r1++ )
  {

    if( o.onPivot )
    o.onPivot.call( o.m,r1,o );

    let row1 = o.m.rowVectorGet( r1 );
    let scaler1 = row1.eGet( r1 );

    if( abs( scaler1 ) < this.accuracy )
    continue;

    vector.mulScalar( row1, 1/scaler1 );

    let xrow1 = o.x.rowVectorGet( r1 );
    vector.mulScalar( xrow1, 1/scaler1 );

    for( let r2 = 0 ; r2 < nrow ; r2++ )
    {

      if( r1 === r2 )
      continue;

      let xrow2 = o.x.rowVectorGet( r2 );
      let row2 = o.m.rowVectorGet( r2 );
      let scaler2 = row2.eGet( r1 );
      let scaler = scaler2;

      vector.subScaled( row2, row1, scaler );
      vector.subScaled( xrow2, xrow1, scaler );

    }

  }

  /* */

  if( o.onPivot && o.pivotingBackward )
  {
    Self.vectorPivotBackward( o.x,o.pivots[ 1 ] );
    /*o.m.pivotBackward( o.pivots );*/
  }

  /* */

  // o.x = this.convertToClass( o.oy.constructor,o.x );
  return o.ox;
}

//

function solveWithGaussJordan()
{
  let o = this._solveOptions( arguments );
  return this._solveWithGaussJordan( o );
}

//

function solveWithGaussJordanPivoting()
{
  let o = this._solveOptions( arguments );
  o.onPivot = this._pivotRook;
  o.pivotingBackward = 1;
  return this._solveWithGaussJordan( o );
}

//

function invertWithGaussJordan()
{
  let m = this;

  _.assert( arguments.length === 0 );
  _.assert( m.dims[ 0 ] === m.dims[ 1 ] );

  let nrow = m.nrow;

  for( let r1 = 0 ; r1 < nrow ; r1++ )
  {

    let row1 = m.rowVectorGet( r1 ).subarray( r1+1 );
    let xrow1 = m.rowVectorGet( r1 ).subarray( 0,r1+1 );

    let scaler1 = 1 / xrow1.eGet( r1 );
    xrow1.eSet( r1, 1 );
    vector.mulScalar( row1, scaler1 );
    vector.mulScalar( xrow1, scaler1 );

    for( let r2 = 0 ; r2 < nrow ; r2++ )
    {

      if( r1 === r2 )
      continue;

      let row2 = m.rowVectorGet( r2 ).subarray( r1+1 );
      let xrow2 = m.rowVectorGet( r2 ).subarray( 0,r1+1 );
      let scaler2 = xrow2.eGet( r1 );
      xrow2.eSet( r1,0 )

      vector.subScaled( row2, row1, scaler2 );
      vector.subScaled( xrow2, xrow1, scaler2 );

    }

    // logger.log( 'm',m );

  }

  return m;
}

//

function solveWithTriangles( x,m,y )
{

  let o = this._solveOptions( arguments );
  m.triangulateLuNormal();

  o.x = this.solveTriangleLower( o.x,o.m,o.y );
  o.x = this.solveTriangleUpperNormal( o.x,o.m,o.x );

  // o.x = this.convertToClass( o.oy.constructor,o.x );
  return o.ox;
}

//

function solveWithTrianglesPivoting( x,m,y )
{

  let o = this._solveOptions( arguments );
  let pivots = m.triangulateLuPivoting();

  o.y = Self.vectorPivotForward( o.y,pivots[ 0 ] );

  o.x = this.solveTriangleLowerNormal( o.x,o.m,o.y );
  o.x = this.solveTriangleUpper( o.x,o.m,o.x );

  Self.vectorPivotBackward( o.x,pivots[ 1 ] );
  Self.vectorPivotBackward( o.y,pivots[ 0 ] );

  // o.x = this.convertToClass( o.oy.constructor,o.x );
  return o.ox;
}

//

function _solveTriangleWithRoutine( args,onSolve )
{
  let x = args[ 0 ];
  let m = args[ 1 ];
  let y = args[ 2 ];

  _.assert( args.length === 3 );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( y );

  if( _.spaceIs( y ) )
  {

    if( x === null )
    {
      x = y.clone();
    }
    else
    {
      x = Self.from( x,y.dims );
      x.copy( y );
    }

    _.assert( x.hasShape( y ) );
    _.assert( x.dims[ 0 ] === m.dims[ 1 ] );

    for( let v = 0 ; v < y.dims[ 1 ] ; v++ )
    {
      onSolve( x.colVectorGet( v ),m,y.colVectorGet( v ) );
    }

    return x;
  }

  /* */

  y = _.vector.from( y );

  if( x === null )
  {
    x = y.clone();
  }
  else
  {
    x = _.vector.from( x );
    x.copy( y );
  }

  /* */

  _.assert( x.length === y.length );

  return onSolve( x,m,y );
}

//

function solveTriangleLower( x,m,y )
{

  function handleSolve( x,m,y )
  {

    for( let r1 = 0 ; r1 < y.length ; r1++ )
    {
      let xu = x.subarray( 0,r1 );
      let row = m.rowVectorGet( r1 );
      let scaler = row.eGet( r1 );
      row = row.subarray( 0,r1 );
      let xval = ( x.eGet( r1 ) - _.vector.dot( row,xu ) ) / scaler;
      x.eSet( r1,xval );
    }

    return x;
  }

  return this._solveTriangleWithRoutine( arguments,handleSolve );
}

//

function solveTriangleLowerNormal( x,m,y )
{

  function handleSolve( x,m,y )
  {

    for( let r1 = 0 ; r1 < y.length ; r1++ )
    {
      let xu = x.subarray( 0,r1 );
      let row = m.rowVectorGet( r1 );
      row = row.subarray( 0,r1 );
      let xval = ( x.eGet( r1 ) - _.vector.dot( row,xu ) );
      x.eSet( r1,xval );
    }

    return x;
  }

  return this._solveTriangleWithRoutine( arguments,handleSolve );
}

//

function solveTriangleUpper( x,m,y )
{

  function handleSolve( x,m,y )
  {

    for( let r1 = y.length-1 ; r1 >= 0 ; r1-- )
    {
      let xu = x.subarray( r1+1,x.length );
      let row = m.rowVectorGet( r1 );
      let scaler = row.eGet( r1 );
      row = row.subarray( r1+1,row.length );
      let xval = ( x.eGet( r1 ) - _.vector.dot( row,xu ) ) / scaler;
      x.eSet( r1,xval );
    }

    return x;
  }

  return this._solveTriangleWithRoutine( arguments,handleSolve );
}

//

function solveTriangleUpperNormal( x,m,y )
{

  function handleSolve( x,m,y )
  {

    for( let r1 = y.length-1 ; r1 >= 0 ; r1-- )
    {
      let xu = x.subarray( r1+1,x.length );
      let row = m.rowVectorGet( r1 );
      row = row.subarray( r1+1,row.length );
      let xval = ( x.eGet( r1 ) - _.vector.dot( row,xu ) );
      x.eSet( r1,xval );
    }

    return x;
  }

  return this._solveTriangleWithRoutine( arguments,handleSolve );
}

//

function solveGeneral( o )
{

  _.assert( arguments.length === 1, 'expects single argument' );
  _.routineOptions( solveGeneral,o );

  /* */

  let result = Object.create( null );
  result.nsolutions = 1;
  result.kernel = o.kernel;
  result.nkernel = 0;

  /* alloc */

  if( o.m.nrow < o.m.ncol )
  {
    let missing = o.m.ncol - o.m.nrow;
    o.m.expand([ [ 0,missing ],0 ]);
    o.y.expand([ [ 0,missing ],0 ]);
  }

  if( !result.kernel )
  result.kernel = Self.makeZero( o.m.dims );
  let nrow = o.m.nrow;

  /* verify */

  _.assert( o.m.nrow === o.y.nrow );
  _.assert( o.m.nrow === result.kernel.nrow );
  _.assert( result.kernel.hasShape( o.m ) );
  _.assert( o.y instanceof Self );
  _.assert( o.y.dims[ 1 ] === 1 );

  /* solve */

  let optionsForMethod;
  if( o.pivoting )
  {
    optionsForMethod = this._solveOptions([ o.x,o.m,o.y ]);
    optionsForMethod.onPivot = this._pivotRook;
    optionsForMethod.pivotingBackward = 0;
    o.x = result.base = this._solveWithGaussJordan( optionsForMethod );
  }
  else
  {
    optionsForMethod = this._solveOptions([ o.x,o.m,o.y ]);
    o.x = result.base = this._solveWithGaussJordan( optionsForMethod );
  }

  /* analyse */

  logger.log( 'm',o.m );
  logger.log( 'x',o.x );

  for( let r = 0 ; r < nrow ; r++ )
  {
    let row = o.m.rowVectorGet( r );
    if( abs( row.eGet( r ) ) < this.accuracy )
    {
      if( abs( o.x.atomGet([ r,0 ]) ) < this.accuracy )
      {
        result.nsolutions = Infinity;
        let termCol = result.kernel.colVectorGet( r );
        let srcCol = o.m.colVectorGet( r );
        termCol.copy( srcCol );
        vector.mulScalar( termCol,-1 );
        termCol.eSet( r,1 );
        result.nkernel += 1;
      }
      else
      {
        debugger;
        result.nsolutions = 0;
        return result;
      }
    }
  }

  if( o.pivoting )
  {
    debugger;
    Self.vectorPivotBackward( result.base,optionsForMethod.pivots[ 1 ] );
    result.kernel.pivotBackward([ optionsForMethod.pivots[ 1 ], optionsForMethod.pivots[ 0 ] ]);
    o.m.pivotBackward( optionsForMethod.pivots );
  }

  return result;
}

solveGeneral.defaults =
{
  x : null,
  m : null,
  y : null,
  kernel : null,
  pivoting : 1,
}

//

function invert()
{
  let self = this;

  _.assert( self.dims.length === 2 );
  _.assert( self.isSquare() );
  _.assert( arguments.length === 0 );

  return self.invertWithGaussJordan();
}

//

function invertingClone()
{
  let self = this;

  _.assert( self.dims.length === 2 );
  _.assert( self.isSquare() );
  _.assert( arguments.length === 0 );

  return Self.solveWithGaussJordan( null,self.clone(),self.Self.makeIdentity( self.dims[ 0 ] ) );
}

//

function copyAndInvert( src )
{
  let self = this;

  _.assert( self.dims.length === 2 );
  _.assert( self.isSquare() );
  _.assert( arguments.length === 1, 'expects single argument' );

  self.copy( src );
  self.invert();

  return self;
}

//

function normalProjectionMatrixMake()
{
  let self = this;
  debugger;
  return self.clone().invert().transpose();
}

//

function normalProjectionMatrixGet( src )
{
  let self = this;

  if( src.hasShape([ 4,4 ]) )
  {
    // debugger;

    let s00 = self.atomGet([ 0,0 ]), s10 = self.atomGet([ 1,0 ]), s20 = self.atomGet([ 2,0 ]);
    let s01 = self.atomGet([ 0,1 ]), s11 = self.atomGet([ 1,1 ]), s21 = self.atomGet([ 2,1 ]);
    let s02 = self.atomGet([ 0,2 ]), s12 = self.atomGet([ 1,2 ]), s22 = self.atomGet([ 2,2 ]);

    let d1 = s22 * s11 - s21 * s12;
    let d2 = s21 * s02 - s22 * s01;
    let d3 = s12 * s01 - s11 * s02;

    let determiant = s00 * d1 + s10 * d2 + s20 * d3;

    if( determiant === 0 )
    throw _.err( 'normalProjectionMatrixGet : zero determinant' );

    determiant = 1 / determiant;

    let d00 = d1 * determiant;
    let d10 = ( s20 * s12 - s22 * s10 ) * determiant;
    let d20 = ( s21 * s10 - s20 * s11 ) * determiant;

    let d01 = d2 * determiant;
    let d11 = ( s22 * s00 - s20 * s02 ) * determiant;
    let d21 = ( s20 * s01 - s21 * s00 ) * determiant;

    let d02 = d3 * determiant;
    let d12 = ( s10 * s02 - s12 * s00 ) * determiant;
    let d22 = ( s11 * s00 - s10 * s01 ) * determiant;

    self.atomSet( [ 0,0 ],d00 );
    self.atomSet( [ 1,0 ],d10 );
    self.atomSet( [ 2,0 ],d20 );

    self.atomSet( [ 0,1 ],d01 );
    self.atomSet( [ 1,1 ],d11 );
    self.atomSet( [ 2,1 ],d21 );

    self.atomSet( [ 0,2 ],d02 );
    self.atomSet( [ 1,2 ],d12 );
    self.atomSet( [ 2,2 ],d22 );

    return self;
  }

  // debugger;
  let sub = src.subspace([ [ 0,src.dims[ 0 ]-1 ],[ 0,src.dims[ 1 ]-1 ] ]);
  // debugger;

  return self.copy( sub ).invert().transpose();
}

// --
// top
// --

function _linearModel( o )
{

  _.routineOptions( polynomExactFor,o );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( o.order >= 1 );

  if( o.points )
  if( o.order === null )
  o.order = o.points.length;

  if( o.npoints === null )
  o.npoints = o.points ? o.points.length : o.order;

  let m = this.makeZero([ o.npoints,o.order ]);
  let ys = [];

  /* */

  let i = 0;
  function fixPoint( p )
  {
    ys[ i ] = p[ 1 ];
    let row = m.rowVectorGet( i )
    for( let d = 0 ; d < o.order ; d++ )
    row.eSet( d,pow( p[ 0 ],d ) );
    i += 1;
  }

  /* */

  if( o.points )
  {

    for( let p = 0 ; p < o.points.length ; p++ )
    fixPoint( o.points[ p ] );

  }
  else
  {

    if( o.domain === null )
    o.domain = [ 0,o.order ]

    _.assert( o.order === o.domain[ 1 ] - o.domain[ 0 ] )

    let x = o.domain[ 0 ];
    while( x < o.domain[ 1 ] )
    {
      let y = o.onFunction( x );
      fixPoint([ x,y ]);
      x += 1;
    }

  }

  /* */

  let result = Object.create( null );

  result.m = m;
  result.y = ys;

  return result;
}

_linearModel.defaults =
{
  npoints : null,
  points : null,
  domain : null,
  order : null,
  onFunction : null,
}

//

function polynomExactFor( o )
{

  _.routineOptions( polynomExactFor,o );
  _.assert( arguments.length === 1, 'expects single argument' );

  if( o.points )
  _.assert( o.order === null || o.order === o.points.length );

  let model = this._linearModel( o );
  let result = this.solve( null , model.m , model.y );

  return result;
}

polynomExactFor.defaults =
{
}

polynomExactFor.defaults.__proto__ = _linearModel.defaults;

//

function polynomClosestFor( o )
{

  _.routineOptions( polynomExactFor,o );
  _.assert( arguments.length === 1, 'expects single argument' );

  let model = this._linearModel( o );

  let mt = model.m.clone().transpose();
  let y = this.mul( null , [ mt , model.y ] );
  let m = this.mul( null , [ mt , model.m ] );

  let result = this.solve( null , m , y );

  return result;
}

polynomClosestFor.defaults =
{
  points : null,
  domain : null,
  order : null,
  onFunction : null,
}

polynomClosestFor.defaults.__proto__ = _linearModel.defaults;

// --
// projector
// --

// function formPerspective( fov, width, height, near, far )
function formPerspective( fov, size, depth )
{
  let self = this;
  let aspect = size[ 0 ] / size[ 1 ];

  // debugger;
  // _.assert( 0,'not tested' );

  _.assert( arguments.length === 3, 'expects exactly three argument' );
  _.assert( size.length === 2 );
  _.assert( depth.length === 2 );
  _.assert( self.hasShape([ 4,4 ]) );

  fov = Math.tan( _.degToRad( fov * 0.5 ) );

  let ymin = - depth[ 0 ] * fov;
  let ymax = - ymin;

  let xmin = ymin;
  let xmax = ymax;

  if( aspect > 1 )
  {

    xmin *= aspect;
    xmax *= aspect;

  }
  else
  {

    ymin /= aspect;
    ymax /= aspect;

  }

  /* logger.log({ xmin : xmin, xmax : xmax, ymin : ymin, ymax : ymax }); */

  return self.formFrustum( [ xmin, xmax ], [ ymin, ymax ], depth );
}

//

// function formFrustum( left, right, bottom, top, near, far )
function formFrustum( horizontal, vertical, depth )
{
  let self = this;

  // debugger;
  // _.assert( 0,'not tested' );

  _.assert( arguments.length === 3, 'expects exactly three argument' );
  _.assert( horizontal.length === 2 );
  _.assert( vertical.length === 2 );
  _.assert( depth.length === 2 );
  _.assert( self.hasShape([ 4,4 ]) );

  // let te = this.buffer;
  let x = 2 * depth[ 0 ] / ( horizontal[ 1 ] - horizontal[ 0 ] );
  let y = 2 * depth[ 0 ] / ( vertical[ 1 ] - vertical[ 0 ] );

  let a = ( horizontal[ 1 ] + horizontal[ 0 ] ) / ( horizontal[ 1 ] - horizontal[ 0 ] );
  let b = ( vertical[ 1 ] + vertical[ 0 ] ) / ( vertical[ 1 ] - vertical[ 0 ] );
  let c = - ( depth[ 1 ] + depth[ 0 ] ) / ( depth[ 1 ] - depth[ 0 ] );
  let d = - 2 * depth[ 1 ] * depth[ 0 ] / ( depth[ 1 ] - depth[ 0 ] );

  self.atomSet( [ 0,0 ],x );
  self.atomSet( [ 1,0 ],0 );
  self.atomSet( [ 2,0 ],0 );
  self.atomSet( [ 3,0 ],0 );

  self.atomSet( [ 0,1 ],0 );
  self.atomSet( [ 1,1 ],y );
  self.atomSet( [ 2,1 ],0 );
  self.atomSet( [ 3,1 ],0 );

  self.atomSet( [ 0,2 ],a );
  self.atomSet( [ 1,2 ],b );
  self.atomSet( [ 2,2 ],c );
  self.atomSet( [ 3,2 ],-1 );

  self.atomSet( [ 0,3 ],0 );
  self.atomSet( [ 1,3 ],0 );
  self.atomSet( [ 2,3 ],d );
  self.atomSet( [ 3,3 ],0 );

  // debugger;
  return self;
}

//

// function formOrthographic( left, right, top, bottom, near, far )
function formOrthographic( horizontal, vertical, depth )
{
  let self = this;

  // debugger;
  // _.assert( 0,'not tested' );

  _.assert( arguments.length === 3, 'expects exactly three argument' );
  _.assert( horizontal.length === 2 );
  _.assert( vertical.length === 2 );
  _.assert( depth.length === 2 );
  _.assert( self.hasShape([ 4,4 ]) );

  let w = horizontal[ 1 ] - horizontal[ 0 ];
  let h = vertical[ 1 ] - vertical[ 0 ];
  let d = depth[ 1 ] - depth[ 0 ];

  let x = ( horizontal[ 1 ] + horizontal[ 0 ] ) / w;
  let y = ( vertical[ 1 ] + vertical[ 0 ] ) / h;
  let z = ( depth[ 1 ] + depth[ 0 ] ) / d;

  self.atomSet( [ 0,0 ],2 / w );
  self.atomSet( [ 1,0 ],0 );
  self.atomSet( [ 2,0 ],0 );
  self.atomSet( [ 3,0 ],0 );

  self.atomSet( [ 0,1 ],0 );
  self.atomSet( [ 1,1 ],2 / h );
  self.atomSet( [ 2,1 ],0 );
  self.atomSet( [ 3,1 ],0 );

  self.atomSet( [ 0,2 ],0 );
  self.atomSet( [ 1,2 ],0 );
  self.atomSet( [ 2,2 ],-2 / d );
  self.atomSet( [ 3,2 ],0 );

  self.atomSet( [ 0,3 ],-x );
  self.atomSet( [ 1,3 ],-y );
  self.atomSet( [ 2,3 ],-z );
  self.atomSet( [ 3,3 ],1 );

  // te[ 0 ] = 2 / w; te[ 4 ] = 0; te[ 8 ] = 0; te[ 12 ] = - x;
  // te[ 1 ] = 0; te[ 5 ] = 2 / h; te[ 9 ] = 0; te[ 13 ] = - y;
  // te[ 2 ] = 0; te[ 6 ] = 0; te[ 10 ] = - 2 / d; te[ 14 ] = - z;
  // te[ 3 ] = 0; te[ 7 ] = 0; te[ 11 ] = 0; te[ 15 ] = 1;

  return self;
}

//

let lookAt = ( function lookAt()
{

  let x = [ 0,0,0 ];
  let y = [ 0,0,0 ];
  let z = [ 0,0,0 ];

  return function( eye, target, up1 )
  {

    debugger;
    _.assert( 0,'not tested' );

    let self = this;
    let te = this.buffer;

    _.avector.subVectors( z, eye, target ).normalize();

    if ( _.avector.mag( z ) === 0 )
    {

      z[ 2 ] = 1;

    }

    debugger;
    _.avector._cross3( x, up1, z );
    let xmag = _.avector.mag( x );

    if ( xmag === 0 )
    {

      z[ 0 ] += 0.0001;
      _.avector._cross3( x,up1, z );
      xmag = _.avector.mag( x );

    }

    _.avector.mulScalar( x,1 / xmag );

    _.avector._cross3( y, z, x );

    te[ 0 ] = x[ 0 ]; te[ 4 ] = y[ 0 ]; te[ 8 ] = z[ 0 ];
    te[ 1 ] = x[ 1 ]; te[ 5 ] = y[ 1 ]; te[ 9 ] = z[ 1 ];
    te[ 2 ] = x[ 2 ]; te[ 6 ] = y[ 2 ]; te[ 10 ] = z[ 2 ];

    return this;
  }

})();

// --
// reducer
// --

function closest( insElement )
{
  let self = this;
  insElement = vector.fromArray( insElement );
  let result =
  {
    index : null,
    distance : +Infinity,
  }

  _.assert( arguments.length === 1, 'expects single argument' );

  for( let i = 0 ; i < self.length ; i += 1 )
  {

    let d = vector.distanceSqr( insElement,self.eGet( i ) );
    if( d < result.distance )
    {
      result.distance = d;
      result.index = i;
    }

  }

  result.distance = sqrt( result.distance );

  return result;
}

//

function furthest( insElement )
{
  let self = this;
  insElement = vector.fromArray( insElement );
  let result =
  {
    index : null,
    distance : -Infinity,
  }

  _.assert( arguments.length === 1, 'expects single argument' );

  for( let i = 0 ; i < self.length ; i += 1 )
  {

    let d = vector.distanceSqr( insElement,self.eGet( i ) );
    if( d > result.distance )
    {
      result.distance = d;
      result.index = i;
    }

  }

  result.distance = sqrt( result.distance );

  return result;
}

//

function elementMean()
{
  let self = this;

  let result = self.elementAdd();

  vector.divScalar( result,self.length );

  return result;
}

//

function minmaxColWise()
{
  let self = this;

  let minmax = self.distributionRangeSummaryValueColWise();
  let result = Object.create( null );

  result.min = self.array.makeSimilar( self.buffer,minmax.length );
  result.max = self.array.makeSimilar( self.buffer,minmax.length );


  for( let i = 0 ; i < minmax.length ; i += 1 )
  {
    result.min[ i ] = minmax[ i ][ 0 ];
    result.max[ i ] = minmax[ i ][ 1 ];
  }

  return result;
}

//

function minmaxRowWise()
{
  let self = this;

  let minmax = self.distributionRangeSummaryValueRowWise();
  let result = Object.create( null );

  result.min = self.array.makeSimilar( self.buffer,minmax.length );
  result.max = self.array.makeSimilar( self.buffer,minmax.length );

  for( let i = 0 ; i < minmax.length ; i += 1 )
  {
    result.min[ i ] = minmax[ i ][ 0 ];
    result.max[ i ] = minmax[ i ][ 1 ];
  }

  return result;
}

//

function determinant()
{
  let self = this;
  let l = self.length;

  if( l === 0 )
  return 0;

  let iterations = _.factorial( l );
  let result = 0;

  _.assert( l === self.atomsPerElement );

  /* */

  let sign = 1;
  let index = [];
  for( let i = 0 ; i < l ; i += 1 )
  index[ i ] = i;

  /* */

  function add()
  {
    let r = 1;
    for( let i = 0 ; i < l ; i += 1 )
    r *= self.atomGet([ index[ i ],i ]);
    r *= sign;
    // console.log( index );
    // console.log( r );
    result += r;
    return r;
  }

  /* */

  function swap( a,b )
  {
    let v = index[ a ];
    index[ a ] = index[ b ];
    index[ b ] = v;
    sign *= -1;
  }

  /* */

  let i = 0;
  while( i < iterations )
  {

    for( let s = 0 ; s < l-1 ; s++ )
    {
      let r = add();
      //console.log( 'add',i,index,r );
      swap( s,l-1 );
      i += 1;
    }

  }

  /* */

  // 00
  // 01
  //
  // 012
  // 021
  // 102
  // 120
  // 201
  // 210

  // console.log( 'determinant',result );

  return result;
}

//

function isDiagonal()
{
  let self = this;

  _.assert( _.Space.is( self ) );

  let cols = self.length;
  let rows = self.atomsPerElement;

  for( let i = 0; i < rows; i++ )
  {
    for( let j = 0; j < cols; j++ )
    {
      debugger;
      if( j !== i && self.atomGet( [ i, j ]) !== 0 )
      return false
    }
  }

  return true;
}

//

function isUpperTriangle( accuracy )
{
  let self = this;

  _.assert( _.Space.is( self ) );

  if( !_.numberIs( accuracy ) || arguments.length === 0 )
  accuracy = 1E-5;

  let cols = self.length;
  let rows = self.atomsPerElement;

  for( let i = 0; i < rows; i++ )
  {
    for( let j = 0; j < cols; j++ )
    {
      debugger;
      if( i > j )
      {
        let point = self.atomGet([ i, j ]);
        if( 0 - accuracy > point || point > 0 + accuracy )
        {
          return false
        }
      }
    }
  }

  return true;
}

//

function isSymmetric( accuracy )
{
  let self = this;

  _.assert( _.Space.is( self ) );

  if( !_.numberIs( accuracy ) || arguments.length === 0 )
  accuracy = 1E-5;

  let cols = self.length;
  let rows = self.atomsPerElement;

  if( cols !== rows )
  {
    return false;
  }


  for( let i = 0; i < rows; i++ )
  {
    for( let j = 0; j < cols; j++ )
    {
      debugger;
      if( i > j )
      {
        let dif = self.atomGet([ i, j ]) - self.atomGet([ j, i ]);
        if( 0 - accuracy > dif || dif > 0 + accuracy )
        {
          return false
        }
      }
    }
  }

  return true;
}

//

function qrIteration( q, r )
{
  let self = this;
  _.assert( _.Space.is( self ) );
  //_.assert( !isNaN( self.clone().invert().atomGet([ 0, 0 ]) ), 'Matrix must be invertible' )

  let cols = self.length;
  let rows = self.atomsPerElement;

  if( arguments.length === 0 )
  {
    var q = _.Space.makeIdentity( [ rows, cols ] );
    var r = _.Space.make([ rows, cols ]);
  }

  let a = self.clone();
  let loop = 0;
  q.copy( _.Space.makeIdentity( rows ) );


  while( a.isUpperTriangle() === false && loop < 1000 )
  {
    var qInt = _.Space.makeIdentity([ rows, cols ]);
    var rInt = _.Space.makeIdentity([ rows, cols ]);
    a.qrDecompositionHH( qInt, rInt );
    // Calculate transformation matrix
    q.mulLeft( qInt );

    a.mul2Matrices( rInt, qInt );

    loop = loop + 1;
  }

  q.copy( q );
  r.copy( a );

  if( loop === 1000 )
  {
    r.copy( rInt );
  }

  let eigenValues = _.vector.toArray( a.diagonalVectorGet() );
  eigenValues.sort( ( a, b ) => b - a );

  logger.log( 'EI',eigenValues)
  for( let i = 0; i < eigenValues.length; i++ )
  {
    let newValue = eigenValues[ i ];
    for( let j = 0; j < eigenValues.length; j++ )
    {
      let value = r.atomGet( [ j, j ] );

      if( newValue === value )
      {
        let oldColQ = q.colVectorGet( i ).clone();
        let oldValue = r.atomGet( [ i, i ] );

        q.colSet( i, q.colVectorGet( j ) );
        q.colSet( j, oldColQ );

        r.atomSet( [ i, i ], r.atomGet( [ j, j ] ) );
        r.atomSet( [ j, j ], oldValue );
      }
    }
  }

  return r.diagonalVectorGet();
}

//

function qrDecompositionGS( q, r )
{
  let self = this;
  _.assert( _.Space.is( self ) );
  _.assert( _.Space.is( q ) );
  _.assert( _.Space.is( r ) );

  let cols = self.length;
  let rows = self.atomsPerElement;

  _.assert( !isNaN( self.clone().invert().atomGet([ 0, 0 ]) ), 'Matrix must be invertible' )

  let matrix = self.clone();
  q.copy( _.Space.makeIdentity( [ rows, cols ] ) );

  let qInt = _.Space.makeIdentity([ rows, cols ]);

  for( let i = 0; i < cols; i++ )
  {
    let col = matrix.colVectorGet( i );
    let sum = _.vector.from( _.array.makeArrayOfLengthZeroed( rows ) );
    for( let j = 0; j < i ; j ++ )
    {
      let dot = _.vector.dot( col, _.vector.from( qInt.colVectorGet( j ) ) );
      debugger;

      _.vector.addVectors( sum, _.vector.mulScalar( _.vector.from( qInt.colVectorGet( j ) ).clone(), - dot ) );
    }
    let e = _.vector.normalize( _.vector.addVectors( col.clone(), sum ) );
    qInt.colSet( i, e );
  }

  // Calculate R
  r.mul2Matrices( qInt.clone().transpose(), matrix );

  // Calculate transformation matrix
  q.mulLeft( qInt );
  let a = _.Space.make([ cols, rows ]);
}

//

function qrDecompositionHH( q, r )
{
  let self = this;
  _.assert( _.Space.is( self ) );
  _.assert( _.Space.is( q ) );
  _.assert( _.Space.is( r ) );

  let cols = self.length;
  let rows = self.atomsPerElement;

  let matrix = self.clone();

  q.copy( _.Space.makeIdentity( rows ) );
  let identity = _.Space.makeIdentity( rows );

  // Calculate Q
  for( let j = 0; j < cols; j++ )
  {
    let u = _.vector.from( _.array.makeArrayOfLengthZeroed( rows ) );
    let e = identity.clone().colVectorGet( j );
    let col = matrix.clone().colVectorGet( j );

    for( let i = 0; i < j; i ++ )
    {
      col.eSet( i, 0 );
    }
    debugger;
    let c = 0;

    if( matrix.atomGet( [ j, j ] ) > 0 )
    {
      c = 1;
    }
    else
    {
      c = -1;
    }

    u = _.vector.addVectors( col, e.mulScalar( c*col.mag() ) ).normalize();

    debugger;
    let m = _.Space.make( [ rows, cols ] ).fromVectors( u, u );
    let h = m.addMatrix( identity, m.mulScalar( - 2 ) );
    q.mulLeft( h );

    matrix = _.Space.mul2Matrices( null, h, matrix );
  }

  r.copy( matrix );

  // Calculate R
  // r.mul2Matrices( h.clone().transpose(), matrix );
  let m = _.Space.mul2Matrices( null, q, r );
  let rb = _.Space.mul2Matrices( null, q.clone().transpose(), self )

  for( let i = 0; i < rows; i++ )
  {
    for( let j = 0; j < cols; j++ )
    {
      if( m.atomGet( [ i, j ] ) < self.atomGet( [ i, j ] ) - 1E-4 )
      {
        throw _.err( 'QR decomposition failed' );
      }

      if( m.atomGet( [ i, j ] ) > self.atomGet( [ i, j ] ) + 1E-4 )
      {
        throw _.err( 'QR decomposition failed' );
      }
    }
  }
}

//

function fromVectors( v1, v2 )
{
  _.assert( _.vectorIs( v1 ) );
  _.assert( _.vectorIs( v2 ) );
  _.assert( v1.length === v2.length );

  let matrix = _.Space.make( [ v1.length, v2.length ] );

  for( let i = 0; i < v1.length; i ++ )
  {
    for( let j = 0; j < v2.length; j ++ )
    {
      matrix.atomSet( [ i, j ], v1.eGet( i )*v2.eGet( j ) );
    }
  }

  return matrix;
}

//

function addMatrix( m1, m2 )
{
  _.assert( _.spaceIs( m1 ) );
  _.assert( _.spaceIs( m2 ) );

  let dims1 = _.Space.dimsOf( m1 ) ;
  let dims2 = _.Space.dimsOf( m2 ) ;
  _.assert( dims1[ 0 ] === dims2[ 0 ] );
  _.assert( dims1[ 1 ] === dims2[ 1 ] );

  let rows = dims1[ 0 ];
  let cols = dims1[ 1 ];

  let matrix = _.Space.make([ rows, cols ]);

  for( let i = 0; i < rows; i ++ )
  {
    for( let j = 0; j < cols; j ++ )
    {
      matrix.atomSet( [ i, j ], m1.atomGet( [ i, j ] ) + m2.atomGet( [ i, j ] ) );
    }
  }

  return matrix;
}

//

function svd( u, s, v )
{
  let self = this;
  _.assert( _.Space.is( self ) );
  _.assert( arguments.length === 3 );

  let dims = _.Space.dimsOf( self );
  let cols = dims[ 1 ];
  let rows = dims[ 0 ];
  let min = rows;
  if( cols < rows )
  min = cols;

  if( arguments[ 0 ] == null )
  var u = _.Space.make([ rows, rows ]);

  if( arguments[ 1 ] == null )
  var s = _.Space.make([ rows, cols ]);

  if( arguments[ 2 ] == null )
  var v = _.Space.make([ cols, cols ]);

  if( self.isSymmetric() === true )
  {
    let q =  _.Space.make( [ cols, rows ] );
    let r =  _.Space.make( [ cols, rows ] );
    let identity = _.Space.makeIdentity( [ cols, rows ] );
    self.qrIteration( q, r );

    let eigenValues = r.diagonalVectorGet();
    for( let i = 0; i < cols; i++ )
    {
      if( eigenValues.eGet( i ) >= 0 )
      {
        u.colSet( i, q.colVectorGet( i ) );
        s.colSet( i, identity.colVectorGet( i ).mulScalar( eigenValues.eGet( i ) ) );
        v.colSet( i, q.colVectorGet( i ) );
      }
      else if( eigenValues.eGet( i ) < 0 )
      {
        u.colSet( i, q.colVectorGet( i ).mulScalar( - 1 ) );
        s.colSet( i, identity.colVectorGet( i ).mulScalar( - eigenValues.eGet( i ) ) );
        v.colSet( i, q.colVectorGet( i ).mulScalar( - 1 ) );
      }
    }
  }
  else
  {
    let aaT = _.Space.mul2Matrices( null, self, self.clone().transpose() );
    let qAAT = _.Space.make( [ rows, rows ] );
    let rAAT = _.Space.make( [ rows, rows ] );

    aaT.qrIteration( qAAT, rAAT );
    let sd = _.Space.mul2Matrices( null, rAAT, qAAT.clone().transpose() )

    u.copy( qAAT );

    let aTa = _.Space.mul2Matrices( null, self.clone().transpose(), self );
    let qATA = _.Space.make( [ cols, cols ] );
    let rATA = _.Space.make( [ cols, cols ] );

    aTa.qrIteration( qATA, rATA );

    let sd1 = _.Space.mul2Matrices( null, rATA, qATA.clone().transpose() )

    v.copy( qATA );

    let eigenV = rATA.diagonalVectorGet();

    for( let i = 0; i < min; i++ )
    {
      if( eigenV.eGet( i ) !== 0 )
      {
        let col = u.colVectorGet( i ).slice();
        let m1 = _.Space.make( [ col.length, 1 ] ).copy( col );
        let m2 = _.Space.mul2Matrices( null, self.clone().transpose(), m1 );

        v.colSet( i, m2.colVectorGet( 0 ).mulScalar( 1 / eigenV.eGet( i ) ).normalize() );
      }
    }


    for( let i = 0; i < min; i++ )
    {
      s.atomSet( [ i, i ], Math.sqrt( Math.abs( rATA.atomGet( [ i, i ] ) ) ) );
    }
  }
}

//
// CONVERSION AND AUXILIARY FUNCTIONS:
//

//Number to HEX
function byteToHex( b )
{
  let hexChar = ["0", "1", "2", "3", "4", "5", "6", "7","8", "9", "A", "B", "C", "D", "E", "F"];
  return hexChar[ ( b >> 4 ) & 0x0f ] + hexChar[ b & 0x0f ];
}

//
// BinaryToByte
function binaryToByte( b )
{
  let byte = 0;
  if( b.charAt( 0 ) ==  1  )
  {
    byte = parseInt( b, 2);
  }
  else if( b.charAt( 0 ) == 0 )
  {
    let c = b.replace( /1/g, '2' );
    let d = c.replace( /0/g, '1' );
    let e = d.replace( /2/g, '0' );
    byte = parseInt( e, 2)*( - 1 );
  }
  return byte;
}

//
// Increase binary number
function increaseBinary( b )
{
  let newBin = parseInt( b, 2 ) + 1;
  let bin = newBin.toString( 2 );
  while( bin.length < b.length )
  {
    bin = '0' + bin;
  }
  return bin;
}

//

function decodeHuffman( components, frameData, hfTables, imageS, index )
{
  let i = index;     // counter
  let numOfBytes = imageS.length;
  _.assert( i < numOfBytes );

  for( let c = 1; c <= components.get( 'numOfComponents' ); c++ )
  {
    for( let vf = 0; vf < frameData.get( 'C' + String( c ) + 'V' ); vf++ )
    {
      for( let hf = 0; hf < frameData.get( 'C' + String( c ) + 'H' ); hf++ )
      {
        let comp = _.array.makeArrayOfLengthZeroed( 64 );

        // DC
        let Dc = 0;
        let table = components.get( 'C' + String( c ) + 'Dc' );
        //Get HT
        let codes;
        let values;

        for( let t = 1; t <= hfTables.size / 6; t++ )
        {
          if( hfTables.get( 'Table' + t + 'AcDc' ) === Dc )
          {
            if( hfTables.get( 'Table' + t + 'ID' ) === table )
            {
              codes = hfTables.get( 'Table' + t + 'Codes' );
              values = hfTables.get( 'Table' + t + 'Values' );
            }
          }
        }

        let num = '';  // bit sequence
        let code = ''; // huffman code
        let value = ''; // value related to the huffman code
        let diffBinary = '';

        while( code === ''  && num.length < 17 )
        {
          num = num + imageS.charAt( i );

          for( let j = 0; j < codes.length; j++ )
          {
            let binaryCode = codes[ j ];

            if( num === binaryCode.toString() )
            {
              code = num;
              value = values[ j ];
            }
          }
          i = i + 1;
          if( num.length === 17 )
          {
            _.assert( value !== '', 'DC H CODE NOT FOUND' )
          }
        }
        //  logger.log('code', code , 'value', value );

        if( value != '00' )
        {
          for( let f = 0; f < parseInt( value ); f++)
          {
            diffBinary = diffBinary + imageS.charAt( i );
            i = i + 1;
          }
          Dc = binaryToByte( diffBinary );

          comp[ 0 ] = Dc;
          _.assert( _.numberIs( comp[ 0 ] ) && !isNaN( comp[ 0 ] ) );
        }
        else
        {
          comp[ 0 ] = 0;
        }
        // logger.log('Get', diffBinary, ' for', comp[ 0 ])

        // AC

        let Ac = 1;
        table = components.get( 'C' + String( c ) + 'Ac' );

        //Get HT
        for( let t = 1; t <= hfTables.size / 6; t++ )
        {
          if( hfTables.get( 'Table' + t + 'AcDc' ) === Ac )
          {
            if( hfTables.get( 'Table' + t + 'ID' ) === table )
            {
              codes = hfTables.get( 'Table' + t + 'Codes' );
              values = hfTables.get( 'Table' + t + 'Values' );
            }
          }
        }

        debugger;
        let j = 1;
        value = ''; // value related to the huffman code
        while( j < 64 && value != '00')
        {
          num = '';  // bit sequence
          code = ''; // huffman code
          value = ''; // value related to the huffman code

          while( code === '' && num.length < 17 )
          {
            num = num + imageS.charAt( i );

            for( let r = 0; r < codes.length; r++ )
            {
              let binaryCode = codes[ r ];
              if( num === binaryCode.toString() )
              {
                code = num;
                value = values[ r ];
              }
            }
            i = i + 1;

            if( num.length === 17 )
            {
              _.assert( value !== '', 'AC H CODE NOT FOUND' )
            }
          }
          //  logger.log('code', code , 'value', value );

          if( value != '00' )
          {
            let binValue = Number( value ).toString( 2 );

            if( binValue.length < 5 )
            {
              let diffBinary = '';
              for( let f = 0; f < parseInt( value ); f++)
              {
                diffBinary = diffBinary + imageS.charAt( i );
                i = i + 1;
              }

              let Ac = binaryToByte( diffBinary );
              comp[ j ] = Ac;
              _.assert( _.numberIs( comp[ j ] ) && !isNaN( comp[ j ] ) );
              //  logger.log('Get', diffBinary, ' for', comp[ j ])
            }
            else
            {
              //  logger.log('ZEROS')
              //  logger.log('Value', value, binValue )
              let newValue = '';
              let zeros = '';

              for( let u = 0; u < binValue.length; u++ )
              {
                if( binValue.length - u > 4 )
                {
                  zeros = zeros + binValue.charAt( u );
                }
                else
                {
                  newValue = newValue + binValue.charAt( u );
                }
              }
              let numZeros = parseInt( zeros, 2 );
              for( let z = 0; z < numZeros; z++ )
              {
                comp[ j ] = 0;
                j = j + 1;
              }
              //  logger.log('Get', zeros, ' for', numZeros, ' zeros')
              let diffBinary = '';
              let numNewValue = parseInt( newValue, 2 );

              for( let f = 0; f < numNewValue; f++)
              {
                diffBinary = diffBinary + imageS.charAt( i );
                i = i + 1;
              }
              let Ac = binaryToByte( diffBinary );

              if( diffBinary === '' )
              Ac = 0;

              comp[ j ] = Ac;

              _.assert( _.numberIs( comp[ j ] ) && !isNaN( comp[ j ] ) );
            }
          }
          j = j + 1;
        }
        components.set( 'C' + String( c ) +'-' + String( vf + 1 ) + String( hf + 1 ), comp );
      }
    }
  }

  index = i;
  return index;
}

//

function dequantizeVector( components, frameData, qTables )
{
  for (var [ key, value ] of components )
  {
    if( typeof( value ) === 'object')
    {
      let tableIndex = frameData.get( 'C' + key.charAt( 1 )+ 'QT' )

      let quant = qTables.get( 'Table' + String( tableIndex ) );
      Array.from( value );
      for( let v = 0; v < value.length; v++ )
      {
        value[ v ] = value[ v ]*quant[ v ];
      }
    }
  }
}

//

function zigzagOrder( components )
{
  for (var [ key, value ] of components )
  {
    if( typeof( value ) === 'object')
    {
      let space = _.Space.make( [ 8, 8 ] );
      Array.from( value );
      let i = [ 0, 0, 1, 2, 1, 0, 0, 1, 2, 3, 4, 3, 2, 1, 0, 0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1, 0, 0, 1, 2,
      3, 4, 5, 6, 7, 7, 6, 5, 4, 3, 2, 1, 2, 3, 4, 5, 6, 7, 7, 6, 5, 4, 3, 4, 5, 6, 7, 7, 6, 5, 6, 7, 7 ];
      let j = [ 0, 1, 0, 0, 1, 2, 3, 2, 1, 0, 0, 1, 2, 3, 4, 5, 4, 3, 2, 1, 0, 0, 1, 2, 3, 4, 5, 6, 7, 6, 5,
      4, 3, 2, 1, 0, 1, 2, 3, 4, 5, 6, 7, 7, 6, 5, 4, 3, 2, 3, 4, 5, 6, 7, 7, 6, 5, 4, 5, 6, 7, 7, 6, 7 ];

      _.assert( value.length === i.length )

      for( let v = 0; v < value.length; v++ )
      {
        space.atomSet( [ i[ v ], j[ v ] ], value[ v ] );
      }
      
      components.set( key, space );
    }
  }
  return components;
}

//

function decodeJPG( jpgPath )
{
  //GET DATA:

  let provider = _.FileProvider.HardDrive();

  let data = provider.fileRead
  ({
    filePath : jpgPath,
    sync : 1,
    encoding : 'buffer.bytes'
  });

  let dataViewByte = Array.from( data );
  let dataViewHex = Array.from( data ).slice();

  // SET MARKERS:

  logger.log( 'IMAGE MARKERS')
  let hfTables = new Map();
  let hf = 0;
  let qTables = new Map();
  let qt = 0;
  let startFrame = 0; // Start of Frame
  let startScan = 0; // Start of Scan
  let endImage = 0; // End of Image

  for( let i = 0; i < dataViewByte.length; i++ )
  {
    dataViewHex[ i ] = byteToHex( dataViewHex[ i ] );
    //logger.log( dataView[ i ]);
    if( i > 0 && dataViewHex[ i - 1 ] === 'FF' )
    {
      if( dataViewHex[ i ] === 'D8' )
      {
        logger.log('Start of Image', i );
      }
      else if( dataViewHex[ i ] === 'DB' )
      {
        logger.log('Quantization Table', i );
        let length = dataViewByte[ i + 1 ]*256 + dataViewByte[ i + 2 ];
        qTables.set( 'Table' + String( qt ) + 'start', i + 3 );
        qTables.set( 'Table' + String( qt ) + 'length', length );
        qt = qt + 1;
      }
      else if( dataViewHex[ i ] === 'C4' )
      {
        logger.log('Huffman Table', i );
        hfTables.set( 'Table' + String( hf + 1 ) + 'start', i + 2 );
        let length = dataViewByte[ i + 1 ]*256 + dataViewByte[ i + 2 ];
        hfTables.set( 'Table' + String( hf + 1 ) + 'end', i + length );
        hf = hf + 1;
      }
      else if( dataViewHex[ i ] === 'DC' )
      {
        logger.log('Number of lines', i );
      }
      else if( dataViewHex[ i ] === 'DA' )
      {
        logger.log('Start of Scan', i );
        startScan = i + 1;
      }
      else if( dataViewHex[ i ] === 'C0' )
      {
        logger.log('Start of Frame', i );
        startFrame = i + 1;
      }
      else if( dataViewHex[ i ] === 'DD' )
      {
        logger.log('Restart interval', i );
      }
      else if( dataViewHex[ i ] === 'FE' )
      {
        logger.log('Comment', i );
      }
      else if( dataViewHex[ i ] === 'E0' )
      {
        logger.log('JFIF specification', i );
      }
      else if( dataViewHex[ i ] === 'D9' )
      {
        logger.log('End of image', i );
        endImage = i;
      }
      else if( dataViewHex[ i ] === '00' )
      {
        logger.log('Stuff byte - remove 00 ', i );
        //dataViewHex[ i ] = '';º11ss
        dataViewHex.splice( i, 1 );
        dataViewByte.splice( i, 1 );
      }
      else
      {
        logger.log( 'Marker without meaning - remove FF: FF ',dataViewHex[ i ] )
        // dataViewHex[ i - 1 ] = '';
        dataViewHex.splice( i - 1, 1 );
        dataViewByte.splice( i - 1, 1 );
      }
    }
  }

  _.assert( hf === 4 || hf === 2, 'JPG doesn´t have 2 or 4 DHT markers')

  // GET IMAGE ( Scan ) DATA:

  let image = _.array.makeArrayOfLengthZeroed( endImage - startScan + 1 );
  let imageH = _.array.makeArrayOfLengthZeroed( endImage - startScan + 1 );
  let imageB = _.array.makeArrayOfLengthZeroed( endImage - startScan + 1 );

  for( let i = 0; i < image.length; i++ )
  {
    image[ i ] = dataViewByte[ startScan + i - 2 ];
    imageH[ i ] = dataViewHex[ startScan + i - 2 ];
    imageB[ i ] = ( dataViewByte[ startScan + i - 2 ] ).toString( 2 );
  }

  //Number of components
  let components = new Map();
  let numOfComponents = image[ 4 ];

  for( let c = 0; c < numOfComponents; c++ )
  {
    // Get Number of HT
    let ac = '';
    let dc = '';
    let component = image[ 5 + 2*c ];
    let type = imageB[ 5 + 2*c + 1 ];

    for( let u = 0; u < type.length; u++ )
    {
      if( type.length < 4 )
      {
        dc = 0;
        ac = ac + type.charAt( u );
      }
      else
      {
        if( type.length - u > 4)
        {
          dc = dc + type.charAt( u );
        }
        else
        {
          ac = ac + type.charAt( u )
        }
      }
    }

    components.set( 'numOfComponents', numOfComponents );
    components.set( 'C' + String( component ) + 'Ac', parseInt( ac, 10 ) );
    components.set( 'C' + String( component ) + 'Dc', parseInt( dc, 10 ) );
  }

  // GET FRAME INFORMATION:

  let frameData = new Map();
  let lengthFrame = 8 + numOfComponents * 3;
  let frameB = _.array.makeArrayOfLength( lengthFrame );
  let frameH = _.array.makeArrayOfLength( lengthFrame );

  for( let f = 0; f < lengthFrame; f ++ )
  {
    frameB[ f ] = dataViewByte[ startFrame + f ];
    frameH[ f ] = dataViewHex[ startFrame + f ];
  }

  let imageHeight = frameB[ 3 ]*256 + frameB[ 4 ];
  let imageWidth = frameB[ 5 ]*256 + frameB[ 6 ];
  _.assert( imageHeight > 0 && imageWidth > 0, 'Image height and width must be superior to zero' );
  let numOfComponentsF = frameB[ 7 ];
  _.assert( numOfComponentsF === numOfComponents, 'Different number of components between frame and scan' );
  logger.log('Dimensions', imageHeight, 'x', imageWidth, 'pixels' )

  // Get Sampling factors and Quantization table code
  let vMax = 0;
  let hMax = 0;
  let numOfQT = 0;
  let oldQT = '';

  for( let cf = 0; cf < numOfComponents; cf++ )
  {
    let component = frameB[ 8 + 3*cf ];
    let samplingF = Number(  frameB[ 8 + 3*cf + 1 ] ).toString( 2 );
    let qT = frameB[ 8 + 3*cf + 2 ];

    if( oldQT !== qT )
    numOfQT = numOfQT + 1;

    oldQT = qT;

    let h = '';
    let v = '';

    for( let u = 0; u < samplingF.length; u++ )
    {
      if( samplingF.length < 4 )
      {
        h = 0;
        v = v + samplingF.charAt( u );
      }
      else
      {
        if( samplingF.length - u > 4)
        {
          h = h + samplingF.charAt( u );
        }
        else
        {
          v = v + samplingF.charAt( u )
        }
      }
    }

    h = parseInt( h, 2);
    v = parseInt( v, 2);

    if( v > vMax )
    vMax = v;

    if( h > hMax )
    hMax = h;

    frameData.set( 'numOfComponents', numOfComponents );
    frameData.set( 'numOfQT', numOfQT );
    frameData.set( 'C' + String( component ) + 'H', h );
    frameData.set( 'C' + String( component ) + 'V', v );
    frameData.set( 'C' + String( component ) + 'QT', qT );
  }
  logger.log('')
  logger.log('FRAME DATA')
  logger.log( frameData );
  logger.log('')

  // GET QUANTIZATION TABLES:

  for( let q = 0; q < qt; q++ )
  {
    let length = qTables.get( 'Table' + String( q ) + 'length' );
    let numOfQTables = length / 65;
    numOfQTables = Math.round( numOfQTables );

    for( let t = 0; t < numOfQTables; t++ )
    {
      let qTable = _.array.makeArrayOfLengthZeroed( 64 );
      for( let e = 0; e < 64; e++ )
      {
        qTable[ e ] = dataViewByte[ qTables.get( 'Table' + String( q ) + 'start' ) + e + 65 * t + 1];
      }
      qTables.set( 'Table' + String( dataViewByte[ qTables.get( 'Table' + String( q ) + 'start' ) + 65 * t ] ), qTable )
    }
  }

  logger.log('')
  logger.log('QUANTIZATION TABLES')
  logger.log( qTables )

  // GET HUFFMAN TABLES:

  function getHuffmanTables( dataViewByte, hfTables )
  {
    let numOfTables = hfTables.size / 2;
    for( let i = 1; i <= numOfTables; i++ )
    {
      let hfTableArray = _.array.makeArrayOfLengthZeroed( hfTables.get( 'Table' + String( i ) + 'end' ) - hfTables.get( 'Table' + String( i ) + 'start' ) );
      let hfTableArrayH = _.array.makeArrayOfLengthZeroed( hfTables.get( 'Table' + String( i ) + 'end' ) - hfTables.get( 'Table' + String( i ) + 'start' ) );


      for( let j = 0; j < hfTableArray.length; j++ )
      {
        hfTableArray[ j ] = dataViewByte[ hfTables.get( 'Table' + String( i ) + 'start' ) + j + 1 ];
        hfTableArrayH[ j ] = dataViewHex[ hfTables.get( 'Table' + String( i ) + 'start' ) + j + 1 ];
      }

      // Get Type And Number of HT
      let type = hfTableArray[ 0 ];
      let typeB = type.toString( 2 );
      let acdc = '';
      let id = '';

      for( let u = 0; u < typeB.length; u++ )
      {
        if( typeB.length < 4 )
        {
          acdc = 0;
        }
        else if( typeB.length - u === 5 )
        {
          acdc = acdc + typeB.charAt( u );
        }

        if( typeB.length - u < 4 )
        {
          id = id + typeB.charAt( u );
        }
      }

      hfTables.set( 'Table' + String( i ) + 'AcDc', parseInt( acdc, 10 ) );
      hfTables.set( 'Table' + String( i ) + 'ID', parseInt( id, 10 ) );

      let hfTableCounters = _.array.makeArrayOfLengthZeroed( 16 );
      for( let i = 0; i < 16; i++ )
      {
        hfTableCounters[ i ] = hfTableArray[ i + 1 ];  // Make Counters array
      }

      // Get Huffman Values
      let v = 0;           // value counter
      let h = new Map();   //Huffman Table

      for( let i = 0; i < 16; i++ )
      {
        let values = _.array.makeArrayOfLengthZeroed( hfTableCounters[ i ] );

        for( let j = 0; j < values.length; j ++ )
        {
          values[ j ] = hfTableArray[ 17 + v ];
          v = v + 1;
        }
        h.set( 'l' + String( i + 1 ), values );
      }

      binaryTree( h );

      let hfTableCodes = _.array.makeArrayOfLengthZeroed( v );
      let hfTableValues = _.array.makeArrayOfLengthZeroed( v );
      let s = 0;
      for( let j = 0; j < 16; j++ )
      {
        let valueArray = h.get( 'l' + String( j + 1 ) );
        if( h.get( 'l' + String( j + 1 ) ).length !== 0 )
        {
          let codeArray = h.get( 'lb' + String( j + 1 ) );
          for( var f = 0; f < valueArray.length; f++ )
          {
            hfTableValues[ s ] = valueArray[ f ];
            hfTableCodes[ s ] = codeArray[ f ];
            s = s + 1;
          }

        }
      }
      hfTables.set( 'Table' + String( i ) + 'Codes', hfTableCodes );
      hfTables.set( 'Table' + String( i ) + 'Values', hfTableValues );
    }

    // Make binary Tree
    function binaryTree( hT )
    {
      let bin = '';  // binary string
      let start = 0;
      for( let i = 0; i < 16; i++ )
      {
        if( hT.get( 'l'+String( i + 1 )).length === 0 )
        {
          bin = bin + '0';
          if( start !== 0 )
          {
            bin = increaseBinary( bin );
          }
        }
        else
        {
          let values = _.array.makeArrayOfLengthZeroed( hT.get( 'l'+String( i + 1 )).length );

          if( start === 0 )
          {
            bin = '0' + bin;
            start = 1;
            values[ 0 ] = bin;

            for( let j = 1; j < values.length; j++ )
            {
              bin = increaseBinary( bin );
              values[ j ] = bin ;
            }
          }
          else
          {
            for( let j = 0; j < values.length; j++ )
            {
              bin = increaseBinary( bin );

              if( j === 0 )
              {
                bin = bin + '0';
              }
              values[ j ] = bin ;
            }
          }
          hT.set( 'lb' + String( i + 1 ), values );
        }
      }
    }
  }

  logger.log('')
  logger.log('HUFFMAN TABLES')
  getHuffmanTables( dataViewByte, hfTables );
  logger.log( hfTables )

  //GET SCAN DATA :

  logger.log('')
  logger.log('START OF SCAN')

  // Number of blocks
  let numOfBlocks = Math.ceil( imageHeight / (8 * hMax ) ) * Math.ceil( imageWidth / ( 8 * vMax ) );
  logger.log('Number of blocks: ', numOfBlocks );

  // Get Scan data bytes
  let length = 2 + image[ 2 ]*256 + image[ 3 ];
  logger.log('Scan length', imageB.length )
  let imageString = '';

  for( let i = length; i < imageB.length; i++ )
  {
    while( imageB[ i ].length < 8 )
    {
      imageB[ i ] = '0' + imageB[ i ];
    }

    _.assert( imageB[ i ].length === 8 );
    imageString = imageString + imageB[ i ].toString();
  }

  // Get Block Info

  // LOOP OVER ALL THE IMAGE
  decodeHuffman( components, frameData, hfTables, imageString, 0 );
  dequantizeVector( components, frameData, qTables );
  zigzagOrder( components );

  for (var [ key, value ] of components )
  {
    if( typeof( value ) === 'object')
    {
      logger.log( key )
      logger.log( value )
      logger.log( '' )
    }
  }
/*
  let index = 0;
  let oldDValues = new Map();
//  for( let b = 0; b < numOfBlocks; b++ )
  for( let b = 0; b < 2; b++ )
  {
    logger.log('');
    logger.log( '16x16 block number', b + 1 );

    index = decodeHuffman( components, frameData, hfTables, imageString, index );

    // Increase DC term
    for (var [ key, value ] of components )
    {
      if( typeof( value ) === 'object')
      {
        Array.from( value );
        if( b !== 0 )
        {
          value[ 0 ] = value[ 0 ] + oldDValues.get( key );
        }
        oldDValues.set( key, value[ 0 ] );
      }
    }

    dequantizeVector( components, frameData, qTables );
    logger.log( 'C1-1', components.get( 'C1-11') )
    logger.log( 'C1-2', components.get( 'C1-12') )
    logger.log( 'C1-3', components.get( 'C1-21') )
    logger.log( 'C1-4', components.get( 'C1-22') )
    logger.log( 'C2-1', components.get( 'C2-11') )
    logger.log( 'C3-1', components.get( 'C3-11') )
  }
*/
}

// --
// relations
// --

let Statics =
{

  /* make */

  make : make,
  makeSquare : makeSquare,
  // makeSquare2 : makeSquare2,
  // makeSquare3 : makeSquare3,
  // makeSquare4 : makeSquare4,

  makeZero : makeZero,
  makeIdentity : makeIdentity,
  makeIdentity2 : makeIdentity2,
  makeIdentity3 : makeIdentity3,
  makeIdentity4 : makeIdentity4,

  makeDiagonal : makeDiagonal,
  makeSimilar : makeSimilar,

  makeLine : makeLine,
  makeCol : makeCol,
  makeColZeroed : makeColZeroed,
  makeRow : makeRow,
  makeRowZeroed : makeRowZeroed,

  fromVectorImage : fromVectorImage,
  fromScalar : fromScalar,
  fromScalarForReading : fromScalarForReading,
  from : from,
  fromForReading : fromForReading,

  _tempBorrow : _tempBorrow,
  tempBorrow : tempBorrow1,
  tempBorrow1 : tempBorrow1,
  tempBorrow2 : tempBorrow2,
  tempBorrow3 : tempBorrow3,

  convertToClass : convertToClass,


  /* mul */

  mul : mul_static,
  mul2Matrices : mul2Matrices_static,


  /* solve */

  _pivotRook : _pivotRook,

  solve : solve,

  _solveOptions : _solveOptions,

  solveWithGausian : solveWithGausian,
  solveWithGausianPivoting : solveWithGausianPivoting,

  _solveWithGaussJordan : _solveWithGaussJordan,
  solveWithGaussJordan : solveWithGaussJordan,
  solveWithGaussJordanPivoting : solveWithGaussJordanPivoting,
  invertWithGaussJordan : invertWithGaussJordan,

  solveWithTriangles : solveWithTriangles,
  solveWithTrianglesPivoting : solveWithTrianglesPivoting,

  _solveTriangleWithRoutine : _solveTriangleWithRoutine,
  solveTriangleLower : solveTriangleLower,
  solveTriangleLowerNormal : solveTriangleLowerNormal,
  solveTriangleUpper : solveTriangleUpper,
  solveTriangleUpperNormal : solveTriangleUpperNormal,

  solveGeneral : solveGeneral,


  /* modeler */

  _linearModel : _linearModel,
  polynomExactFor : polynomExactFor,
  polynomClosestFor : polynomClosestFor,


  /* var */

  _tempMatrices : [ Object.create( null ) , Object.create( null ) , Object.create( null ) ],

}

/*
map
filter
reduce
zip
*/

// --
// declare
// --

let Extend =
{

  // make

  make : make,
  makeSquare : makeSquare,

  // makeSquare2 : makeSquare2,
  // makeSquare3 : makeSquare3,
  // makeSquare4 : makeSquare4,

  makeZero : makeZero,

  makeIdentity : makeIdentity,
  makeIdentity2 : makeIdentity2,
  makeIdentity3 : makeIdentity3,
  makeIdentity4 : makeIdentity4,

  makeDiagonal : makeDiagonal,
  makeSimilar : makeSimilar,

  makeLine : makeLine,
  makeCol : makeCol,
  makeColZeroed : makeColZeroed,
  makeRow : makeRow,
  makeRowZeroed : makeRowZeroed,

  // convert

  convertToClass : convertToClass,

  fromVectorImage : fromVectorImage,
  fromScalar : fromScalar,
  fromScalarForReading : fromScalarForReading,
  from : from,
  fromForReading : fromForReading,

  fromTransformations : fromTransformations,
  fromQuat : fromQuat,
  fromQuatWithScale : fromQuatWithScale,

  fromAxisAndAngle : fromAxisAndAngle,

  fromEuler : fromEuler,

  // borrow

  _tempBorrow : _tempBorrow,
  tempBorrow : tempBorrow1,
  tempBorrow1 : tempBorrow1,
  tempBorrow2 : tempBorrow2,
  tempBorrow3 : tempBorrow3,

  // mul

  pow : spacePow,
  mul : mul,
  mul2Matrices : mul2Matrices,
  mulLeft : mulLeft,
  mulRight : mulRight,

  // partial accessors

  zero : zero,
  identify : identify,
  diagonalSet : diagonalSet,
  diagonalVectorGet : diagonalVectorGet,
  triangleLowerSet : triangleLowerSet,
  triangleUpperSet : triangleUpperSet,

  // transformer

  matrixApplyTo : matrixApplyTo,
  matrixHomogenousApply : matrixHomogenousApply,
  matrixDirectionsApply : matrixDirectionsApply,

  positionGet : positionGet,
  positionSet : positionSet,
  scaleMaxGet : scaleMaxGet,
  scaleMeanGet : scaleMeanGet,
  scaleMagGet : scaleMagGet,
  scaleGet : scaleGet,
  scaleSet : scaleSet,
  scaleAroundSet : scaleAroundSet,
  scaleApply : scaleApply,

  // triangulator

  _triangulateGausian : _triangulateGausian,
  triangulateGausian : triangulateGausian,
  triangulateGausianNormal : triangulateGausianNormal,
  triangulateGausianPivoting : triangulateGausianPivoting,

  triangulateLu : triangulateLu,
  triangulateLuNormal : triangulateLuNormal,
  triangulateLuPivoting : triangulateLuPivoting,

  _pivotRook : _pivotRook,

  // solver

  solve : solve,

  _solveOptions : _solveOptions,

  solveWithGausian : solveWithGausian,
  solveWithGausianPivoting : solveWithGausianPivoting,

  _solveWithGaussJordan : _solveWithGaussJordan,
  solveWithGaussJordan : solveWithGaussJordan,
  solveWithGaussJordanPivoting : solveWithGaussJordanPivoting,
  invertWithGaussJordan : invertWithGaussJordan,

  solveWithTriangles : solveWithTriangles,
  solveWithTrianglesPivoting : solveWithTrianglesPivoting,

  _solveTriangleWithRoutine : _solveTriangleWithRoutine,
  solveTriangleLower : solveTriangleLower,
  solveTriangleLowerNormal : solveTriangleLowerNormal,
  solveTriangleUpper : solveTriangleUpper,
  solveTriangleUpperNormal : solveTriangleUpperNormal,

  solveGeneral : solveGeneral,

  invert : invert,
  invertingClone : invertingClone,
  copyAndInvert : copyAndInvert,

  normalProjectionMatrixMake : normalProjectionMatrixMake,
  normalProjectionMatrixGet : normalProjectionMatrixGet,

  // modeler

  _linearModel : _linearModel,

  polynomExactFor : polynomExactFor,
  polynomClosestFor : polynomClosestFor,

  // projector

  formPerspective : formPerspective,
  formFrustum : formFrustum,
  formOrthographic : formOrthographic,
  lookAt : lookAt,

  // reducer

  closest : closest,
  furthest : furthest,

  elementMean : elementMean,

  minmaxColWise : minmaxColWise,
  minmaxRowWise : minmaxRowWise,

  determinant : determinant,

  isDiagonal : isDiagonal,
  isUpperTriangle : isUpperTriangle,
  isSymmetric : isSymmetric,

  qrIteration : qrIteration,
  qrDecompositionGS : qrDecompositionGS,
  qrDecompositionHH : qrDecompositionHH,

  fromVectors : fromVectors,
  addMatrix : addMatrix,

  svd : svd,

  byteToHex : byteToHex,
  binaryToByte : binaryToByte,
  increaseBinary : increaseBinary,
  decodeHuffman : decodeHuffman,
  dequantizeVector : dequantizeVector,
  zigzagOrder : zigzagOrder,
  decodeJPG : decodeJPG,

  //

  Statics : Statics,

}

_.classExtend( Self, Extend );
_.assert( Self.from === from );
_.assert( Self.mul2Matrices === mul2Matrices_static );
_.assert( Self.prototype.mul2Matrices === mul2Matrices );

})();
