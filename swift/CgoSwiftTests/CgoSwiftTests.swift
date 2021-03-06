import XCTest
@testable import CgoSwift

class CgoSwiftTests: XCTestCase {
  func testSimple() {
    print(x_Add(2, 1))
    print(x_AddAndSub(2, 1))
    var a: Int32 = 0, b: Int32 = 0
    x_AddAndSubPtrs(2, 1, &a, &b)
    print(a, b)
    print(x_Sqrt(16))
  }

  func testDiv() {
    // Note, the function calls below leak x_VError memory.
    print(x_Div(6, 3))
    var a: Int32 = 0
    var err = x_VError()
    x_DivPtrs(6, 3, &a, &err)
    print(a, err)
    print(x_Div(6, 0))
    x_DivPtrs(6, 0, &a, &err)
    print(a, err)
  }

  func testCFuncs() {
    print(c_SimpleFunc(2))
    print(c_Add(5, 6))
  }

  func testIdiomatic() {
    print(addAndSub(3, b: 1))
    print(try! div(9, b: 3))
    do {
      try div(9, b: 0)
      assert(false)
    } catch let e {
      print(e)
    }
    print(echo("foo"))
    let arr = "arr".dataUsingEncoding(NSUTF8StringEncoding)!
    print(try! echoFoo(Foo(str: "str", arr: arr, num: 42)))
    do {
      try echoFoo(Foo(str: "str", arr: arr, num: 0))
      assert(false)
    } catch let e {
      print(e)
    }
  }

  func testIdiomaticAsync() {
    let n: Int32 = 5
    var sum: Int32 = 0
    var start = NSDate()
    streamInts(n, onInt: { sum += $0 })
    print("streamInts took ", NSDate().timeIntervalSinceDate(start))
    XCTAssertEqual(sum, 10)
    sum = 0
    start = NSDate()
    let done = expectationWithDescription("asyncStreamInts")
    asyncStreamInts(n, onInt: { sum += $0 }, onDone: { print("asyncStreamInts took ", NSDate().timeIntervalSinceDate(start)); done.fulfill() })
    waitForExpectationsWithTimeout(5) { error in
      XCTAssertNil(error)
      XCTAssertEqual(sum, 10)
    }
  }
}
