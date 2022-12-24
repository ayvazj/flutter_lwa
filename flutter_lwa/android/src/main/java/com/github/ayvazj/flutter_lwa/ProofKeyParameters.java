package com.github.ayvazj.flutter_lwa;
import androidx.annotation.NonNull;

final class ProofKeyParameters {
    public final String codeChallenge;
    public final String codeChallengeMethod;

    ProofKeyParameters(@NonNull String codeChallenge, @NonNull String codeChallengeMethod) {
        this.codeChallenge = codeChallenge;
        this.codeChallengeMethod = codeChallengeMethod;
    }
}
