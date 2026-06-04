// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_creation_vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TokenCreationViewModel)
final tokenCreationViewModelProvider = TokenCreationViewModelProvider._();

final class TokenCreationViewModelProvider
    extends $NotifierProvider<TokenCreationViewModel, TokenCreationState> {
  TokenCreationViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenCreationViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenCreationViewModelHash();

  @$internal
  @override
  TokenCreationViewModel create() => TokenCreationViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenCreationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenCreationState>(value),
    );
  }
}

String _$tokenCreationViewModelHash() =>
    r'7890037bd0b69f68800afbf23895413f7c897869';

abstract class _$TokenCreationViewModel extends $Notifier<TokenCreationState> {
  TokenCreationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TokenCreationState, TokenCreationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TokenCreationState, TokenCreationState>,
              TokenCreationState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
