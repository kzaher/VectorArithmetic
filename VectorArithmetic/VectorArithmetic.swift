import CoreGraphics

protocol VectorOperatable  {
  init(horizontal:Double,vertical:Double)
  var horizontal:Double { get set }
  var vertical:Double { get set }

}

protocol VectorArithmetic : VectorOperatable {
  
  var angleInRadians:Double {get}
  var magnitude:Double {get}
  var lengthSquared:Double {get}
  var length:Double {get}
  func dotProduct <T : VectorArithmetic>(vector:T) -> Double
  func distanceTo <T : VectorArithmetic>(vector:T) -> Double
  
  var reversed:Self {get}
  mutating func reverse()

  var normalized:Self {get}
  mutating func normalize()
  
  func limited(scalar:Double) -> Self
  mutating func limit(scalar:Double)
  
  func scaled(scalar:Double) -> Self
  mutating func scale(scalar:Double)
  
  func angled(scalar:Double) -> Self
  mutating func angle(scalar:Double)
  
}


@infix func == <T:VectorOperatable, U:VectorOperatable> (lhs:T,rhs:U) -> Bool {
    return (lhs.horizontal == rhs.horizontal && lhs.vertical == rhs.vertical)
}
@infix func != <T:VectorOperatable, U:VectorOperatable>(lhs: T , rhs: U) -> Bool {
  return (lhs == rhs) == false
}
@infix func <= <T:VectorOperatable, U:VectorOperatable>(lhs:T, rhs:U) -> Bool {
    return (lhs.horizontal <=  rhs.horizontal && lhs.vertical <= rhs.vertical)
}
@infix func < <T:VectorOperatable, U:VectorOperatable>(lhs: T , rhs: U) -> Bool {
  return (lhs.horizontal <  rhs.horizontal && lhs.vertical < rhs.vertical)
}
@infix func >= <T:VectorOperatable, U:VectorOperatable>(lhs: T , rhs: U) -> Bool {
    return (lhs.horizontal >= rhs.horizontal && lhs.vertical >= rhs.vertical)
}
@infix func > <T:VectorOperatable, U:VectorOperatable>(lhs: T , rhs: U) -> Bool {
    return (lhs < rhs) == false
}
@infix func - <T:VectorOperatable, U:VectorOperatable>(lhs: T, rhs:U) -> T  {
  return T(horizontal: lhs.horizontal-rhs.horizontal, vertical: lhs.vertical-rhs.vertical)
}
@assignment  @infix func -= <T:VectorOperatable, U:VectorOperatable>(inout lhs: T, rhs:U)  {
  lhs = lhs - rhs
}

@infix func + <T:VectorOperatable, U:VectorOperatable>(lhs: T, rhs:U) -> T  {
  return T(horizontal: lhs.horizontal+rhs.horizontal, vertical: lhs.vertical+rhs.vertical)
}
@assignment  @infix func += <T:VectorOperatable, U:VectorOperatable>(inout lhs: T, rhs:U)  {
  lhs = lhs + rhs
}

@infix func * <T:VectorOperatable, U:VectorOperatable>(lhs: T, rhs:U) -> T  {
  return T(horizontal: lhs.horizontal*rhs.horizontal, vertical: lhs.vertical*rhs.vertical);
}
@assignment @infix func *= <T:VectorOperatable, U:VectorOperatable>(inout lhs: T, rhs:U)  {
  lhs = lhs * rhs
  
}

@infix func / <T:VectorOperatable, U:VectorOperatable>(lhs:T, rhs:U) -> T  {
  return T(horizontal: lhs.horizontal/rhs.horizontal, vertical: lhs.vertical/rhs.vertical);
}
@assignment @infix func /= <T:VectorOperatable, U:VectorOperatable>(inout lhs:T, rhs:U) -> T  {
  lhs = lhs / rhs
  return lhs
}


@infix func / <T:VectorOperatable>(lhs:T, scalar:Double) -> T  {
  return T(horizontal: lhs.horizontal/scalar, vertical: lhs.vertical/scalar);
}
@assignment  @infix func /= <T:VectorOperatable>(inout lhs:T, scalar:Double) -> T  {
  lhs = lhs / scalar
  return lhs
}

@infix func * <T:VectorOperatable>(lhs: T, scalar:Double) -> T  {
  return T(horizontal: lhs.horizontal*scalar, vertical: lhs.vertical*scalar)
}
@assignment @infix func *= <T:VectorOperatable>(inout lhs: T, value:Double)   {
  lhs = lhs * value
}



struct InternalVectorArithmetic {
    
  static func angleInRadians  <T : VectorArithmetic>(vector:T) -> Double {
    let normalized = vector.normalized
    let theta = atan2(normalized.vertical, normalized.horizontal)
    return theta + M_PI_2 * -1
  }
  
  static func magnitude <T : VectorArithmetic>(vector:T) -> Double {
    return sqrt(vector.dotProduct(vector))
  }
  
  static func lengthSquared <T : VectorArithmetic>(vector:T) -> Double {
    return ((vector.horizontal*vector.horizontal) + (vector.vertical*vector.vertical))
  }
  
  
  static func reversed <T : VectorArithmetic>(vector:T) -> T {
    return vector * -1
  }
  
  static func dotProduct <T : VectorOperatable, U : VectorOperatable > (vector:T, otherVector:U) -> Double  {
    return (vector.horizontal*otherVector.horizontal) + (vector.vertical*otherVector.vertical)
  }
  
  
  static func distanceTo <T : VectorArithmetic, U : VectorArithmetic > (vector:T, otherVector:U) -> Double {
    var deltaX = Double.abs(vector.horizontal - otherVector.horizontal)
    var deltaY = Double.abs(vector.vertical   - otherVector.vertical)
    return T(horizontal: deltaX, vertical: deltaY).magnitude
  }
  
  
  
  static func normalized <T : VectorArithmetic>(vector:T) -> T {
    let length = vector.length
    var newPoint:T = vector
    if(length > 0.0) {
      newPoint /= length
    }
    return newPoint
  }
  
  static func limit <T : VectorArithmetic>(vector:T, scalar:Double) -> T  {
    var newPoint = vector
    if(vector.magnitude > scalar) {
      newPoint = newPoint.normalized * scalar
    }
    return newPoint
  }

  
  static func scale <T : VectorArithmetic>(vector :T, scalar:Double) -> T {
    return vector.normalized * scalar
  }
  
  static func vectorWithAngle <T:VectorArithmetic>(vector:T, scalar:Double) -> T {
    let length = vector.length
    return T(horizontal: cos(scalar) * length, vertical: sin(scalar) * length)
    }
}


extension CGPoint: VectorArithmetic  {

  
  init(horizontal:Double,vertical:Double) {
    self.init(x: horizontal, y: vertical)
  }
  
#if !(arch(x86_64) || arch(arm64))
  init(x:Double, y:Double) {
    self.init(x:CGFloat(x), y:CGFloat(y))
  }
  var horizontal:Double {
    get { return Double(self.x)      }
    set { self.x = CGFloat(newValue) }
  }
  var vertical:Double {
    get {return Double(self.y)       }
    set {self.y = CGFloat(newValue)  }
  }
  
#else
  var horizontal:Double {
    get { return self.x     }
    set { self.x = newValue }
  }
  var vertical:Double {
    get { return self.y     }
    set { self.y = newValue }
  }
#endif

  var angleInRadians:Double { return InternalVectorArithmetic.angleInRadians(self)}
  var magnitude:Double { return InternalVectorArithmetic.magnitude(self) }
  var length:Double { return self.magnitude }
  var lengthSquared:Double { return InternalVectorArithmetic.lengthSquared(self) }
  func dotProduct <T : VectorArithmetic> (vector:T) -> Double { return InternalVectorArithmetic.dotProduct(self, otherVector: vector) }
  func distanceTo <T : VectorArithmetic> (vector:T) -> Double { return InternalVectorArithmetic.distanceTo(self, otherVector: vector) }
  var reversed:CGPoint { return InternalVectorArithmetic.reversed(self) }
  mutating func reverse() { self = self.reversed }
  var normalized:CGPoint { return InternalVectorArithmetic.normalized(self) }
  mutating func normalize() { self = self.normalized }
  func limited(scalar:Double) -> CGPoint { return InternalVectorArithmetic.limit(self, scalar: scalar) }
  mutating func limit(scalar:Double) { self  = self.limited(scalar); }
  func scaled(scalar:Double) -> CGPoint { return InternalVectorArithmetic.scale(self, scalar: scalar) }
  mutating func scale(scalar:Double) { self = self.scaled(scalar) }
  func angled(scalar:Double) -> CGPoint { return InternalVectorArithmetic.vectorWithAngle(self, scalar: scalar) }
  mutating func angle(scalar:Double) { self = self.angled(scalar); }
  
}


extension CGSize: VectorArithmetic   {

  init(horizontal:Double,vertical:Double) {
    self.init(width: horizontal, height: vertical)
  }

#if !(arch(x86_64) || arch(arm64))
  init(width:Double, height:Double) {
    self.init(width:CGFloat(width), height:CGFloat(height))
  }
  var horizontal:Double {
    get { return Double(self.width)      }
    set { self.width = CGFloat(newValue) }
  }
  var vertical:Double {
    get {return Double(self.height)       }
    set {self.height = CGFloat(newValue)  }
  }
  
  #else
  var horizontal:Double {
    get { return self.width }
    set { self.width = newValue }
  }
  var vertical:Double {
    get { return self.height     }
    set { self.height = newValue }
  }
  #endif
  
  
  var angleInRadians:Double { return InternalVectorArithmetic.angleInRadians(self) }
  var magnitude:Double { return InternalVectorArithmetic.magnitude(self) }
  var length:Double { return self.magnitude }
  var lengthSquared:Double { return InternalVectorArithmetic.lengthSquared(self) }
  func dotProduct <T : VectorArithmetic> (vector:T) -> Double { return InternalVectorArithmetic.dotProduct(self, otherVector: vector) }
  func distanceTo <T : VectorArithmetic> (vector:T) -> Double { return InternalVectorArithmetic.distanceTo(self, otherVector: vector) }
  var reversed:CGSize { return InternalVectorArithmetic.reversed(self) }
  mutating func reverse() { self = self.reversed }
  var normalized:CGSize { return InternalVectorArithmetic.normalized(self) }
  mutating func normalize() { self = self.normalized }
  func limited(scalar:Double) -> CGSize { return InternalVectorArithmetic.limit(self, scalar: scalar) }
  mutating func limit(scalar:Double) { self  = self.limited(scalar); }
  func scaled(scalar:Double) -> CGSize { return InternalVectorArithmetic.scale(self, scalar: scalar) }
  mutating func scale(scalar:Double) { self = self.scaled(scalar) }
  func angled(scalar:Double) -> CGSize { return InternalVectorArithmetic.vectorWithAngle(self, scalar: scalar) }
  mutating func angle(scalar:Double) { self = self.angled(scalar) }
  
  
}

extension CGVector: VectorArithmetic   {
  
  init(horizontal:Double,vertical:Double) {
    self.dx = CGFloat(horizontal)
    self.dy = CGFloat(vertical)

  }
  
#if !(arch(x86_64) || arch(arm64))
  init(_ dx:Double, _ dy:Double) {
    self.dx = CGFloat(dx)
    self.dy = CGFloat(dy)
  }
  
  var horizontal:Double {
    get { return Double(self.dy)      }
    set { self.dy = CGFloat(newValue) }
  }
  var vertical:Double {
    get {return Double(self.dy)       }
    set {self.dy = CGFloat(newValue)  }
  }
  
#else
  var horizontal:Double {
    get { return self.dx     }
    set { self.dx = newValue }
  }
  var vertical:Double {
    get { return self.dy     }
    set { self.dy = newValue }
  }
#endif

  var angleInRadians:Double { return InternalVectorArithmetic.angleInRadians(self) }
  var magnitude:Double { return InternalVectorArithmetic.magnitude(self) }
  var length:Double { return self.magnitude }
  var lengthSquared:Double { return InternalVectorArithmetic.lengthSquared(self) }
  func dotProduct <T : VectorArithmetic> (vector:T) -> Double { return InternalVectorArithmetic.dotProduct(self, otherVector: vector) }
  func distanceTo <T : VectorArithmetic> (vector:T) -> Double { return InternalVectorArithmetic.distanceTo(self, otherVector: vector) }
  var reversed:CGVector { return InternalVectorArithmetic.reversed(self) }
  mutating func reverse() { self = self.reversed }
  var normalized:CGVector { return InternalVectorArithmetic.normalized(self) }
  mutating func normalize() { self = self.normalized }
  func limited(scalar:Double) -> CGVector { return InternalVectorArithmetic.limit(self, scalar: scalar) }
  mutating func limit(scalar:Double) { self  = self.limited(scalar); }
  func scaled(scalar:Double) -> CGVector { return InternalVectorArithmetic.scale(self, scalar: scalar) }
  mutating func scale(scalar:Double) { self = self.scaled(scalar) }
  func angled(scalar:Double) -> CGVector { return InternalVectorArithmetic.vectorWithAngle(self, scalar: scalar) }
  mutating func angle(scalar:Double) { self = self.angled(scalar) }

}