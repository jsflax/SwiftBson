//
//  CodecRegistries.swift
//  bson
//
//  Created by Jason Flax on 11/22/17.
//  Copyright © 2017 mongodb. All rights reserved.
//

import Foundation

public struct CodecRegistries {
    /**
     * Creates a {@code CodecRegistry} from the provided list of {@code Codec} instances.
     *
     * <p>This registry can then be used alongside other registries.  Typically used when adding extra codecs to existing codecs with the
     * {@link #fromRegistries(CodecRegistry...)} )} helper.</p>
     *
     * @param codecs the {@code Codec} to create a registry for
     * @return a {@code CodecRegistry} for the given list of {@code Codec} instances.
     */
    public static func fromCodecs(codecs: BoxedCodec...) -> CodecRegistry {
        return fromProviders(providers: MapOfCodecsProvider(codecsList: codecs))
    }

    /**
     * Creates a {@code CodecRegistry} from the provided list of {@code CodecProvider} instances.
     *
     * <p>The created instance can handle cycles of {@code Codec} dependencies, i.e when the construction of a {@code Codec} for class A
     * requires the construction of a {@code Codec} for class B, and vice versa.</p>
     *
     * @param providers the codec provider
     * @return a {@code CodecRegistry} with the ordered list of {@code CodecProvider} instances. The registry is also guaranteed to be an
     * instance of {code CodecProvider}, so that when one is passed to {@link #fromRegistries(CodecRegistry...)} or {@link
     * #fromRegistries(java.util.List)} it will be treated as a {@code CodecProvider} and properly resolve any dependencies between
     * registries.
     */
    public static func fromProviders(providers: CodecProvider...) -> CodecRegistry {
        return ProvidersCodecRegistry(codecProviders: providers)
    }

    /**
     * A {@code CodecRegistry} that combines the given {@code CodecRegistry} instances into a single registry.
     *
     * <p>The registries are checked in order until one returns a {@code Codec} for the requested {@code Class}.</p>
     *
     * <p>The created instance can handle cycles of {@code Codec} dependencies, i.e when the construction of a {@code Codec} for class A
     * requires the construction of a {@code Codec} for class B, and vice versa.</p>

     * <p>Any of the given registries that also implement {@code CodecProvider} will be treated as a {@code CodecProvider} instead of a
     * {@code CodecRegistry}, which will ensure proper resolution of any dependencies between registries.</p>
     *
     * @param registries the preferred registry for {@code Codec} lookups
     *
     * @return a {@code CodecRegistry} that combines the list of {@code CodecRegistry} instances into a single one
     */
    public static func fromRegistries(registries: CodecRegistry...) -> CodecRegistry {
        return ProvidersCodecRegistry(codecProviders: registries.flatMap { providerFromRegistry(innerRegistry: $0) })
    }

    private static func providerFromRegistry(innerRegistry: CodecRegistry) -> CodecProvider? {
        if let registry = innerRegistry as? CodecProvider {
            return registry
        } else {
            return nil
        }
    }

    private init() {
    }
}

