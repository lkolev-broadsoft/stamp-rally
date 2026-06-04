import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/utils/code_generator.dart';
import '../../../shared/utils/qr_validator.dart';
import '../../../shared/utils/stamp_signer.dart';
import '../../../shared/utils/stamp_token.dart';
import '../../events/models/event.dart';
import '../models/operator.dart';

final operatorSessionProvider =
    StateNotifierProvider<OperatorSessionController, OperatorSession>((ref) {
  return OperatorSessionController();
});

class OperatorSessionController extends StateNotifier<OperatorSession> {
  OperatorSessionController() : super(const OperatorSession());

  static const _uuid = Uuid();

  bool loginWithPin({
    required String pin,
    required List<Operator> operators,
  }) {
    final normalizedPin = pin.trim();
    for (final operator in operators) {
      if (operator.pin == normalizedPin) {
        state = OperatorSession(operator: operator);
        return true;
      }
    }

    state = state.copyWith(errorMessage: 'Unknown operator PIN.');
    return false;
  }

  void clearIssuedStamp() {
    state = OperatorSession(operator: state.operator);
  }

  bool acceptPassportPayload({
    required Event event,
    required PassportQrPayload payload,
  }) {
    final operator = state.operator;
    if (operator == null) {
      state = state.copyWith(errorMessage: 'Operator PIN is required.');
      return false;
    }

    if (payload.eventId != event.id || payload.eventId != operator.eventId) {
      state = state.copyWith(errorMessage: 'Passport belongs to another event.');
      return false;
    }

    final confirmationCode = generateConfirmationCode(
      eventId: payload.eventId,
      passportId: payload.passportId,
      displayNonce: payload.displayNonce,
    );

    state = OperatorSession(
      operator: operator,
      passportPayload: payload,
      confirmationCode: confirmationCode,
    );
    return true;
  }

  Future<StampToken?> issueStamp({required Event event}) async {
    final operator = state.operator;
    final payload = state.passportPayload;
    if (operator == null || payload == null) {
      state = state.copyWith(errorMessage: 'Scan a passport before issuing.');
      return null;
    }

    if (event.checkpointById(operator.checkpointId) == null) {
      state = state.copyWith(errorMessage: 'Operator checkpoint is unknown.');
      return null;
    }

    final unsignedToken = StampToken(
      tokenId: _uuid.v4(),
      eventId: payload.eventId,
      passportId: payload.passportId,
      checkpointId: operator.checkpointId,
      operatorId: operator.id,
      issuedAt: DateTime.now().toUtc(),
      keyId: operator.keyId,
      signature: '',
    );

    final signature = await StampSigner.signPayload(
      payload: unsignedToken.unsignedPayload(),
      privateSeedBase64: operator.privateSeedBase64,
    );

    final token = StampToken(
      tokenId: unsignedToken.tokenId,
      eventId: unsignedToken.eventId,
      passportId: unsignedToken.passportId,
      checkpointId: unsignedToken.checkpointId,
      operatorId: unsignedToken.operatorId,
      issuedAt: unsignedToken.issuedAt,
      keyId: unsignedToken.keyId,
      signature: signature,
    );

    state = state.copyWith(issuedToken: token, errorMessage: null);
    return token;
  }
}

class OperatorSession {
  const OperatorSession({
    this.operator,
    this.passportPayload,
    this.issuedToken,
    this.confirmationCode,
    this.errorMessage,
  });

  final Operator? operator;
  final PassportQrPayload? passportPayload;
  final StampToken? issuedToken;
  final String? confirmationCode;
  final String? errorMessage;

  OperatorSession copyWith({
    Operator? operator,
    PassportQrPayload? passportPayload,
    StampToken? issuedToken,
    String? confirmationCode,
    String? errorMessage,
  }) {
    return OperatorSession(
      operator: operator ?? this.operator,
      passportPayload: passportPayload ?? this.passportPayload,
      issuedToken: issuedToken ?? this.issuedToken,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      errorMessage: errorMessage,
    );
  }
}
