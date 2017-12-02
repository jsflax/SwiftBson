/*
 * Copyright 2017 MongoDB, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

/**
 * The options to apply to a {@code ClientSession}.
 *
 * @mongodb.server.release 3.6
 * @since 3.6
 * @see ClientSession
 * @mongodb.driver.dochub core/causal-consistency Causal Consistency
 */
public struct ClientSessionOptions {
    /**
     * Whether operations using the session should causally consistent with each other.
     *
     * @return whether operations using the session should be causally consistent.  A null value indicates to use the the global default,
     * which is currently true.
     * @mongodb.driver.dochub core/causal-consistency Causal Consistency
     */
    var isCasuallyConsistent: Bool = true

    /**
     * A builder for instances of {@code ClientSession}
     */
    typealias Builder = (inout ClientSessionOptions) -> Void

    init(builder: Builder) {
        builder(&self)
    }
}
