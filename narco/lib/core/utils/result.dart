sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) =>
      switch (this) {
        Success(data: final d) => success(d),
        Failure(message: final m) => failure(m),
      };
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const Failure(this.message, {this.error, this.stackTrace});
}
