// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransferViewModel)
final transferViewModelProvider = TransferViewModelProvider._();

final class TransferViewModelProvider
    extends $NotifierProvider<TransferViewModel, TransferState> {
  TransferViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transferViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transferViewModelHash();

  @$internal
  @override
  TransferViewModel create() => TransferViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransferState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransferState>(value),
    );
  }
}

String _$transferViewModelHash() => r'553d6f659225389aceae3755402893f4a4882661';

abstract class _$TransferViewModel extends $Notifier<TransferState> {
  TransferState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TransferState, TransferState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TransferState, TransferState>,
              TransferState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
