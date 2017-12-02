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
 * An enumeration of the MongodDB-supported authentication mechanisms.
 *
 * @since 3.0
 */
public enum AuthenticationMechanism: String {
    /**
     * The GSSAPI mechanism.  See the <a href="http://tools.ietf.org/html/rfc4752">RFC</a>.
     */
    case gssapi = "GSSAPI",

    /**
     * The PLAIN mechanism.  See the <a href="http://www.ietf.org/rfc/rfc4616.txt">RFC</a>.
     */
    plain = "PLAIN",

    /**
     * The MongoDB X.509 mechanism. This mechanism is available only with client certificates over SSL.
     */
    mongodbX509 = "MONGODB-X509",

    /**
     * The MongoDB Challenge Response mechanism.
     */
    mongodbCR = "MONGODB-CR",

    /**
     * The SCRAM-SHA-1 mechanism.  See the <a href="http://tools.ietf.org/html/rfc5802">RFC</a>.
     */
    scramSha1 = "SCRAM-SHA-1"
}
