enum RoleEnum {
  valora,
  guardian;

  @override
  String toString() {
    switch (this) {
      case RoleEnum.valora:
        return 'Valora';
      case RoleEnum.guardian:
        return 'Guardian';
    }
  }
}
