////
////  ByteBufImpl.swift
////  bson
////
////  Created by Jason Flax on 12/4/17.
////  Copyright © 2017 mongodb. All rights reserved.
////
//
//import Foundation
//
///**
// * Implementation of {@code ByteBuf} which simply wraps an NIO {@code ByteBuffer} and forwards all calls to it.
// *
// * @since 3.0
// */
//public class ByteBufImpl: ByteBuf {
//    private var buf: [Byte]? = [Byte]()
//    private let _referenceCount = AtomicInteger(1)
//
//    /**
//     * Creates a new instance.
//     *
//     * @param buf the {@code ByteBuffer} to wrap.
//     */
//    public init(buf: [Byte]) {
//        self.buf = buf
//    }
//
//    public func referenceCount() {
//        return _referenceCount.get()
//    }
//
//    public func retain() -> ByteBufImpl {
//        if _referenceCount.incrementAndGet() == 1 {
//            _referenceCount.decrementAndGet()
//            throw RuntimeError.illegalState("Attempted to increment the reference count when it is already 0")
//        }
//        return self
//    }
//
//    public func release() {
//        if _referenceCount.decrementAndGet() < 0 {
//            _referenceCount.incrementAndGet()
//            throw RuntimeError.illegalState("Attempted to decrement the reference count below 0");
//        }
//        if _referenceCount.get() == 0 {
//            buf = nil
//        }
//    }
//
//    public func capacity() -> Int {
//        return buf!.capacity
//    }
//
//    public func put(index: Int, b: Byte) -> ByteBufImpl {
//        buf![index] = b
//        return self
//    }
//
//    public func remaining() -> Int {
//        return buf!.capacity - buf!.count
//    }
//
//    public func put(final byte[] src, final int offset, final int length) {
//        buf.put(src, offset, length);
//        return this;
//    }
//
//    public func hasRemaining() -> Bool {
//        return buf.hasRemaining();
//    }
//
//    @Override
//    public ByteBuf put(final byte b) {
//        buf.put(b);
//        return this;
//    }
//
//    @Override
//    public ByteBuf flip() {
//        ((Buffer) buf).flip();
//        return this;
//    }
//
//    @Override
//    public byte[] array() {
//        return buf.array();
//    }
//
//    @Override
//    public int limit() {
//        return buf.limit();
//    }
//
//    @Override
//    public ByteBuf position(final int newPosition) {
//        ((Buffer) buf).position(newPosition);
//        return this;
//    }
//
//    @Override
//    public ByteBuf clear() {
//        ((Buffer) buf).clear();
//        return this;
//    }
//
//    @Override
//    public ByteBuf order(final ByteOrder byteOrder) {
//        buf.order(byteOrder);
//        return this;
//    }
//
//    @Override
//    public byte get() {
//        return buf.get();
//    }
//
//    @Override
//    public byte get(final int index) {
//        return buf.get(index);
//    }
//
//    @Override
//    public ByteBuf get(final byte[] bytes) {
//        buf.get(bytes);
//        return this;
//    }
//
//    @Override
//    public ByteBuf get(final int index, final byte[] bytes) {
//        return get(index, bytes, 0, bytes.length);
//    }
//
//    @Override
//    public ByteBuf get(final byte[] bytes, final int offset, final int length) {
//        buf.get(bytes, offset, length);
//        return this;
//    }
//
//    @Override
//    public ByteBuf get(final int index, final byte[] bytes, final int offset, final int length) {
//        for (int i = 0; i < length; i++) {
//            bytes[offset + i] = buf.get(index + i);
//        }
//        return this;
//    }
//
//    @Override
//    public long getLong() {
//        return buf.getLong();
//    }
//
//    @Override
//    public long getLong(final int index) {
//        return buf.getLong(index);
//    }
//
//    @Override
//    public double getDouble() {
//        return buf.getDouble();
//    }
//
//    @Override
//    public double getDouble(final int index) {
//        return buf.getDouble(index);
//    }
//
//    @Override
//    public int getInt() {
//        return buf.getInt();
//    }
//
//    @Override
//    public int getInt(final int index) {
//        return buf.getInt(index);
//    }
//
//    public func position() {
//        return buf!.count
//    }
//
//    @Override
//    public ByteBuf limit(final int newLimit) {
//        ((Buffer) buf).limit(newLimit);
//        return this;
//    }
//}

