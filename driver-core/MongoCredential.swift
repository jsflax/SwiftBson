//
//  MongoCredential.swift
//  swift-driver
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 Jason Flax. All rights reserved.
//

import Foundation

/**
 * Represents credentials to authenticate to a mongo server,as well as the source of
 * the credentials and the authentication mechanism to use.
 *
 * @since 2.11
 */
public class MongoCredential {
    private let mechanism: AuthenticationMechanism?
    private let userName: String?
    private let source: String
    private let password: String?

    private var mechanismProperties: [String: Any]

    /**
     * Mechanism property key for overriding the service name for GSSAPI authentication.
     *
     * @see #createGSSAPICredential(String)
     * @see #withMechanismProperty(String, Object)
     * @since 3.3
     */
    public static let serviceNameKey = "SERVICE_NAME";

    /**
     * Mechanism property key for specifying whether to canonicalize the host name for GSSAPI authentication.
     *
     * @see #createGSSAPICredential(String)
     * @see #withMechanismProperty(String, Object)
     * @since 3.3
     */
    public static let canonicalizeHostName = "CANONICALIZE_HOST_NAME";

    /**
     * Mechanism property key for overriding the SaslClient properties for GSSAPI authentication.
     *
     * The value of this property must be a {@code Map<String, Object>}.  In most cases there is no need to set this mechanism property.
     * But if an application does:
     * <ul>
     * <li>Generally it must set the {@link javax.security.sasl.Sasl#CREDENTIALS} property to an instance of
     * {@link org.ietf.jgss.GSSCredential}.</li>
     * <li>It's recommended that it set the {@link javax.security.sasl.Sasl#MAX_BUFFER} property to "0" to ensure compatibility with all
     * versions of MongoDB.</li>
     * </ul>
     *
     * @see #createGSSAPICredential(String)
     * @see #withMechanismProperty(String, Object)
     * @see javax.security.sasl.Sasl
     * @see javax.security.sasl.Sasl#CREDENTIALS
     * @see javax.security.sasl.Sasl#MAX_BUFFER
     * @since 3.3
     */
    public static let javaSASLClientProperties = "JAVA_SASL_CLIENT_PROPERTIES";

    /**
     * Mechanism property key for overriding the {@link javax.security.auth.Subject} under which GSSAPI authentication executes.
     *
     * @see #createGSSAPICredential(String)
     * @see #withMechanismProperty(String, Object)
     * @since 3.3
     */
    public static let javaSubjectKey = "JAVA_SUBJECT";

    /**
     * Creates a MongoCredential instance with an unspecified mechanism.  The client will negotiate the best mechanism based on the
     * version of the server that the client is authenticating to.  If the server version is 3.0 or higher,
     * the driver will authenticate using the SCRAM-SHA-1 mechanism.  Otherwise, the driver will authenticate using the MONGODB_CR
     * mechanism.
     *
     *
     * @param userName the user name
     * @param database the database where the user is defined
     * @param password the user's password
     * @return the credential
     *
     * @since 2.13
     * @mongodb.driver.manual core/authentication/#mongodb-cr-authentication MONGODB-CR
     * @mongodb.driver.manual core/authentication/#authentication-scram-sha-1 SCRAM-SHA-1
     */
    public static func createCredential(userName: String,
                                        database: String,
                                        password: String) -> MongoCredential {
        return MongoCredential(mechanism: nil, userName: userName, source: database, password: password)
    }

    /**
     * Creates a MongoCredential instance for the SCRAM-SHA-1 SASL mechanism. Use this method only if you want to ensure that
     * the driver uses the SCRAM-SHA-1 mechanism regardless of whether the server you are connecting to supports the
     * authentication mechanism.  Otherwise use the {@link #createCredential(String, String, char[])} method to allow the driver to
     * negotiate the best mechanism based on the server version.
     *
     *
     * @param userName the non-null user name
     * @param source the source where the user is defined.
     * @param password the non-null user password
     * @return the credential
     * @see #createCredential(String, String, char[])
     *
     * @since 2.13
     * @mongodb.server.release 3.0
     * @mongodb.driver.manual core/authentication/#authentication-scram-sha-1 SCRAM-SHA-1
     */
    public static func createScramSha1Credential(userName: String,
                                                 source: String,
                                                 password: String) -> MongoCredential {
        return MongoCredential(mechanism: .scramSha1, userName: userName, source: source, password: password)
    }

    /**
     * Creates a MongoCredential instance for the MongoDB Challenge Response protocol. Use this method only if you want to ensure that
     * the driver uses the MONGODB_CR mechanism regardless of whether the server you are connecting to supports a more secure
     * authentication mechanism.  Otherwise use the {@link #createCredential(String, String, char[])} method to allow the driver to
     * negotiate the best mechanism based on the server version.
     *
     * @param userName the user name
     * @param database the database where the user is defined
     * @param password the user's password
     * @return the credential
     * @see #createCredential(String, String, char[])
     * @mongodb.driver.manual core/authentication/#mongodb-cr-authentication MONGODB-CR
     */
    public static func createMongoCRCredential(userName: String,
                                               database: String,
                                               password: String) -> MongoCredential {
        return MongoCredential(mechanism: .mongodbCR, userName: userName, source: database, password: password)
    }

    /**
     * Creates a MongoCredential instance for the MongoDB X.509 protocol.
     *
     * @param userName the user name
     * @return the credential
     *
     * @since 2.12
     * @mongodb.server.release 2.6
     * @mongodb.driver.manual core/authentication/#x-509-certificate-authentication X-509
     */
    public static func createMongoX509Credential(userName: String) -> MongoCredential {
        return MongoCredential(mechanism: .mongodbX509, userName: userName, source: "$external", password: nil)
    }

    /**
     * Creates a MongoCredential instance for the MongoDB X.509 protocol where the distinguished subject name of the client certificate
     * acts as the userName.
     * <p>
     *     Available on MongoDB server versions &gt;= 3.4.
     * </p>
     * @return the credential
     *
     * @since 3.4
     * @mongodb.server.release 3.4
     * @mongodb.driver.manual core/authentication/#x-509-certificate-authentication X-509
     */
    public static func createMongoX509Credential() -> MongoCredential {
        return MongoCredential(mechanism: .mongodbX509, userName: nil, source: "$external", password: nil)
    }

    /**
     * Creates a MongoCredential instance for the PLAIN SASL mechanism.
     *
     * @param userName the non-null user name
     * @param source   the source where the user is defined.  This can be either {@code "$external"} or the name of a database.
     * @param password the non-null user password
     * @return the credential
     *
     * @since 2.12
     * @mongodb.server.release 2.6
     * @mongodb.driver.manual core/authentication/#ldap-proxy-authority-authentication PLAIN
     */
    public static func createPlainCredential(userName: String, source: String, password: String) -> MongoCredential {
        return MongoCredential(mechanism: .plain, userName: userName, source: source, password: password)
    }

    /**
     * Creates a MongoCredential instance for the GSSAPI SASL mechanism.
     * <p>
     * To override the default service name of {@code "mongodb"}, add a mechanism property with the name {@code "SERVICE_NAME"}.
     * <p>
     * To force canonicalization of the host name prior to authentication, add a mechanism property with the name
     * {@code "CANONICALIZE_HOST_NAME"} with the value{@code true}.
     * <p>
     * To override the {@link javax.security.auth.Subject} with which the authentication executes, add a mechanism property with the name
     * {@code "JAVA_SUBJECT"} with the value of a {@code Subject} instance.
     * <p>
     * To override the properties of the {@link javax.security.sasl.SaslClient} with which the authentication executes, add a mechanism
     * property with the name {@code "JAVA_SASL_CLIENT_PROPERTIES"} with the value of a {@code Map<String, Object} instance containing the
     * necessary properties.  This can be useful if the application is customizing the default
     * {@link javax.security.sasl.SaslClientFactory}.
     *
     * @param userName the non-null user name
     * @return the credential
     * @mongodb.server.release 2.4
     * @mongodb.driver.manual core/authentication/#kerberos-authentication GSSAPI
     * @see #withMechanismProperty(String, Object)
     * @see #SERVICE_NAME_KEY
     * @see #CANONICALIZE_HOST_NAME_KEY
     * @see #JAVA_SUBJECT_KEY
     * @see #JAVA_SASL_CLIENT_PROPERTIES_KEY
     */
    public static func createGSSAPICredential(userName: String) -> MongoCredential {
        return MongoCredential(mechanism: .gssapi, userName: userName, source: "$external", password: nil)
    }

    /**
     * Creates a new MongoCredential as a copy of this instance, with the specified mechanism property added.
     *
     * @param key   the key to the property, which is treated as case-insensitive
     * @param value the value of the property
     * @param <T>   the property type
     * @return the credential
     * @since 2.12
     */
    public func withMechanismProperty<T>(key: String, value: T) -> MongoCredential {
        return MongoCredential(from: self, mechanismPropertyKey: key,
                               mechanismPropertyValue: value)
    }

    /**
     * Constructs a new instance using the given mechanism, userName, source, and password
     *
     * @param mechanism the authentication mechanism
     * @param userName  the user name
     * @param source    the source of the user name, typically a database name
     * @param password  the password
     */
    private init(mechanism: AuthenticationMechanism?, userName: String?, source: String, password: String?) {
        self.mechanism = mechanism
        self.userName = userName
        self.source =  source

        self.password = password
        self.mechanismProperties = [:]
    }

    /**
     * Constructs a new instance using the given credential plus an additional mechanism property.
     *
     * @param from                   the credential to copy from
     * @param mechanismPropertyKey   the new mechanism property key
     * @param mechanismPropertyValue the new mechanism property value
     * @param <T>                    the mechanism property type
     */
    init<T>(from: MongoCredential, mechanismPropertyKey: String, mechanismPropertyValue: T) {
        self.mechanism = from.mechanism;
        self.userName = from.userName;
        self.source = from.source;
        self.password = from.password;
        self.mechanismProperties = from.mechanismProperties
        self.mechanismProperties[mechanismPropertyKey.lowercased()] = mechanismPropertyValue
    }

    /**
     * Get the value of the given key to a mechanism property, or defaultValue if there is no mapping.
     *
     * @param key          the mechanism property key, which is treated as case-insensitive
     * @param defaultValue the default value, if no mapping exists
     * @param <T>          the value type
     * @return the mechanism property value
     * @since 2.12
     */
    public func getMechanismProperty<T>(key: String, defaultValue: T) -> T {
        let value: T? = mechanismProperties[key.lowercased()] as? T
        return value ?? defaultValue
    }
}

extension MongoCredential: Hashable, Equatable {
    public var hashValue: Int {
        var result = mechanism?.hashValue ?? 0
        result = 31 * result + (userName?.hashValue ?? 0)
        result = 31 * result + source.hashValue
        result = 31 * result + (password?.hashValue ?? 0)
        result = 31 * result + mechanismProperties.reduce(0, { (hash: Int, arg0) -> Int in
            return 31 * hash + arg0.key.hashValue
        })
        return result
    }

    public static func ==(lhs: MongoCredential, rhs: MongoCredential) -> Bool {
        return lhs.mechanism == rhs.mechanism &&
            lhs.password == rhs.password &&
            lhs.source == rhs.source &&
            lhs.userName == rhs.userName &&
            lhs.mechanismProperties.elementsEqual(rhs.mechanismProperties, by: { (arg0, arg1)  -> Bool in
                return arg1.key == arg0.key
            })
    }
}

extension MongoCredential: CustomStringConvertible {
    public var description: String {
        return """
        MongoCredential {
            mechanism=\(String(describing: mechanism)),
            userName=\(String(describing: userName)),
            source=\(source),
            password=<hidden>,
            mechanismProperties=\(mechanismProperties)
        }
        """
    }
}
