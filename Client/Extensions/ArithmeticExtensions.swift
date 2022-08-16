// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// See https://github.com/neevaco/neeva-ios/pull/1004#issuecomment-882558870
// for an explanation of why these functions (and only these functions) are implemented

@inlinable func * <I: BinaryInteger>(lhs: CGFloat, rhs: I) -> CGFloat {
    lhs * CGFloat(rhs)
}
@inlinable func * <I: BinaryInteger>(lhs: I, rhs: CGFloat) -> CGFloat {
    CGFloat(lhs) * rhs
}

// This is not commutative (i.e. BinaryInteger / CGFloat) because it seems likely to result in errors
@inlinable func / <I: BinaryInteger>(lhs: CGFloat, rhs: I) -> CGFloat {
    lhs / CGFloat(rhs)
}

extension FloatingPoint {
    /// Apply the provided sign to this number.
    @inlinable func withSign(_ sign: FloatingPointSign) -> Self {
        Self(sign: sign, exponent: exponent, significand: significand)
    }
}
