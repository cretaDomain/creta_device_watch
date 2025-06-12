import 'package:equatable/equatable.dart';

class FortuneCookie extends Equatable {
  final String message;

  const FortuneCookie({required this.message});

  @override
  List<Object?> get props => [message];
}
