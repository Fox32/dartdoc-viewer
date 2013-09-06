/**
 * Implement missing methods from element so that we don't get swamped
 * with warnings about them.
 */

class StopBotheringMe {
  getAttributeNS(a, b) => throw "Unimplemented";
  getAttribute(a) => throw "Unimplemented";
  setAttribute(a, b) => throw "Unimplemented";
  get childNodes => throw "Unimplemented";
  setAttributeNS(a, b, c) => throw "Unimplemented";
}